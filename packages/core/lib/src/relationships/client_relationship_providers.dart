import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'client_relationship_repository.dart';
import 'models.dart';
import 'supabase_client_relationship_repository.dart';

/// Real by default; override in a `ProviderScope` with the fake for tests or
/// offline screen work, the same way [authRepositoryProvider] is overridden.
final clientRelationshipRepositoryProvider =
    Provider<ClientRelationshipRepository>(
      (ref) => SupabaseClientRelationshipRepository(),
    );

/// Every relationship row a dietitian owns, pending ones included — the panel
/// shows both so an invite is visible while it waits.
final dietitianClientsProvider =
    FutureProvider.family<List<ClientRelationship>, String>((ref, dietitianId) {
      return ref
          .watch(clientRelationshipRepositoryProvider)
          .fetchForDietitian(dietitianId);
    });

/// Names for the active subset, joined to the rows above by client id.
final dietitianClientNamesProvider =
    FutureProvider.family<List<ClientName>, String>((ref, dietitianId) {
      return ref
          .watch(clientRelationshipRepositoryProvider)
          .fetchClientNames(dietitianId);
    });

final pendingInvitesProvider = FutureProvider<List<ClientRelationship>>((ref) {
  return ref
      .watch(clientRelationshipRepositoryProvider)
      .fetchPendingInvitesForMe();
});
