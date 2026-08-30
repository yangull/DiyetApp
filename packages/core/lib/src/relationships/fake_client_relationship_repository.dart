import 'client_relationship_repository.dart';
import 'models.dart';

/// In-memory stand-in for tests. Unlike the real one this enforces nothing —
/// RLS is what actually restricts access, and it cannot run here — so a test
/// that wants to prove isolation must seed the other party's rows and assert
/// they are filtered out by the query arguments, not by this class.
class FakeClientRelationshipRepository implements ClientRelationshipRepository {
  FakeClientRelationshipRepository({this.currentUserId, this.currentEmail});

  /// Who [acceptInvite] claims the row for, and whose invites
  /// [fetchPendingInvitesForMe] returns. Stands in for the JWT.
  String? currentUserId;
  String? currentEmail;

  final _relationships = <ClientRelationship>[];
  final _names = <String, String>{};

  int _nextId = 1;

  void seedRelationship({
    required String dietitianId,
    required String invitedEmail,
    String? clientId,
    RelationshipStatus status = RelationshipStatus.pending,
    String? id,
  }) {
    _relationships.add(
      ClientRelationship(
        id: id ?? 'rel-${_nextId++}',
        dietitianId: dietitianId,
        clientId: clientId,
        invitedEmail: invitedEmail.trim().toLowerCase(),
        status: status,
        createdAt: DateTime(2026, 8, 29),
      ),
    );
  }

  /// The name `list_my_clients()` would return for an active client.
  void seedClientName(String clientId, String fullName) {
    _names[clientId] = fullName;
  }

  ClientRelationship byId(String id) =>
      _relationships.firstWhere((r) => r.id == id);

  @override
  Future<void> inviteClient({
    required String dietitianId,
    required String email,
  }) async {
    final normalized = email.trim().toLowerCase();
    final duplicate = _relationships.any(
      (r) =>
          r.dietitianId == dietitianId &&
          r.invitedEmail == normalized &&
          r.status == RelationshipStatus.pending,
    );
    // Mirrors the partial unique index, so the UI's duplicate handling is
    // reachable in a test without a database.
    if (duplicate) throw StateError('Duplicate pending invite: $normalized');
    seedRelationship(dietitianId: dietitianId, invitedEmail: normalized);
  }

  @override
  Future<List<ClientRelationship>> fetchForDietitian(
    String dietitianId,
  ) async => _relationships.where((r) => r.dietitianId == dietitianId).toList();

  @override
  Future<List<ClientName>> fetchClientNames(String dietitianId) async {
    return _relationships
        .where(
          (r) =>
              r.dietitianId == dietitianId && r.isActive && r.clientId != null,
        )
        .map(
          (r) => ClientName(
            clientId: r.clientId!,
            fullName: _names[r.clientId] ?? 'Adsız Danışan',
          ),
        )
        .toList();
  }

  @override
  Future<List<ClientRelationship>> fetchPendingInvitesForMe() async {
    final email = currentEmail?.toLowerCase();
    if (email == null) return const [];
    return _relationships
        .where(
          (r) => r.isPending && r.clientId == null && r.invitedEmail == email,
        )
        .toList();
  }

  @override
  Future<void> acceptInvite(String relationshipId) async =>
      _replace(relationshipId, RelationshipStatus.active, currentUserId);

  @override
  Future<void> declineInvite(String relationshipId) async =>
      _replace(relationshipId, RelationshipStatus.declined, null);

  void _replace(String id, RelationshipStatus status, String? clientId) {
    final index = _relationships.indexWhere((r) => r.id == id);
    if (index == -1) throw StateError('No seeded relationship: $id');
    final current = _relationships[index];
    _relationships[index] = ClientRelationship(
      id: current.id,
      dietitianId: current.dietitianId,
      clientId: clientId,
      invitedEmail: current.invitedEmail,
      status: status,
      createdAt: current.createdAt,
    );
  }
}
