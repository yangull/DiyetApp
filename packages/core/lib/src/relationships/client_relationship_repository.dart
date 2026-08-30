import 'models.dart';

/// Reads and writes for `dietitian_client_relationships`.
///
/// Every method is scoped by RLS to the caller: a dietitian sees only their
/// own rows, a client only invites addressed to their verified email. The
/// arguments here are what the query needs, not a permission claim — passing
/// someone else's id returns nothing rather than someone else's data.
abstract class ClientRelationshipRepository {
  /// Creates a pending invite. The email is normalized before it is stored:
  /// it is compared against the JWT email claim when the client accepts, and
  /// it backs a `lower(...)` unique index.
  Future<void> inviteClient({
    required String dietitianId,
    required String email,
  });

  Future<List<ClientRelationship>> fetchForDietitian(String dietitianId);

  /// Names of the dietitian's active clients, in one call. Separate from
  /// [fetchForDietitian] because names come from a `security definer`
  /// projection rather than the relationship table itself.
  Future<List<ClientName>> fetchClientNames(String dietitianId);

  /// Pending invites addressed to the signed-in user's email.
  Future<List<ClientRelationship>> fetchPendingInvitesForMe();

  Future<void> acceptInvite(String relationshipId);

  Future<void> declineInvite(String relationshipId);
}
