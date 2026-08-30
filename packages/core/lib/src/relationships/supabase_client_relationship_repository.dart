import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'client_relationship_repository.dart';
import 'models.dart';

const _columns =
    'id, dietitian_id, client_id, invited_email, status, created_at';

RelationshipStatus _parseStatus(String value) =>
    RelationshipStatus.values.firstWhere((s) => s.name == value);

ClientRelationship _toRelationship(Map<String, dynamic> row) =>
    ClientRelationship(
      id: row['id'] as String,
      dietitianId: row['dietitian_id'] as String,
      clientId: row['client_id'] as String?,
      invitedEmail: row['invited_email'] as String,
      status: _parseStatus(row['status'] as String),
      createdAt: DateTime.parse(row['created_at'] as String),
    );

class SupabaseClientRelationshipRepository
    implements ClientRelationshipRepository {
  sb.SupabaseClient get _db => sb.Supabase.instance.client;

  @override
  Future<void> inviteClient({
    required String dietitianId,
    required String email,
  }) async {
    await _db.from('dietitian_client_relationships').insert({
      'dietitian_id': dietitianId,
      'invited_email': email.trim().toLowerCase(),
    });
  }

  @override
  Future<List<ClientRelationship>> fetchForDietitian(String dietitianId) async {
    final rows = await _db
        .from('dietitian_client_relationships')
        .select(_columns)
        .eq('dietitian_id', dietitianId)
        .order('created_at');
    return rows.map(_toRelationship).toList();
  }

  @override
  Future<List<ClientName>> fetchClientNames(String dietitianId) async {
    // The function reads auth.uid() itself; dietitianId is not passed.
    final rows = await _db.rpc('list_my_clients') as List;
    return rows
        .cast<Map<String, dynamic>>()
        .map(
          (row) => ClientName(
            clientId: row['client_id'] as String,
            fullName: row['full_name'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<List<ClientRelationship>> fetchPendingInvitesForMe() async {
    // No filter on email: the RLS policy already restricts this to invites
    // addressed to the caller's JWT email claim.
    final rows = await _db
        .from('dietitian_client_relationships')
        .select(_columns)
        .eq('status', RelationshipStatus.pending.name)
        .isFilter('client_id', null)
        .order('created_at');
    return rows.map(_toRelationship).toList();
  }

  @override
  Future<void> acceptInvite(String relationshipId) async {
    await _db
        .from('dietitian_client_relationships')
        .update({
          'client_id': _db.auth.currentUser!.id,
          'status': RelationshipStatus.active.name,
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', relationshipId);
  }

  @override
  Future<void> declineInvite(String relationshipId) async {
    // client_id stays null: declining does not claim the row, and the
    // decline policy's WITH CHECK requires it to stay null.
    await _db
        .from('dietitian_client_relationships')
        .update({
          'status': RelationshipStatus.declined.name,
          'responded_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', relationshipId);
  }
}
