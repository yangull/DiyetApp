import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_repository.dart';
import 'models.dart';
import 'profile_repository.dart';
import 'supabase_auth_repository.dart';
import 'supabase_profile_repository.dart';

/// Real by default; override both in a `ProviderScope` with the fakes for
/// tests or offline screen work.
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(),
);

final sessionProvider = StreamProvider<AuthSession?>(
  (ref) => ref.watch(authRepositoryProvider).sessionChanges,
);

/// Fetches the profile plus whichever detail row matches its role. Keyed by
/// user id so a fresh sign-in gets a fresh fetch; `ref.invalidate` on this
/// (by id) is what "Durumu Yenile" calls to re-check verification status.
final identityProvider = FutureProvider.family<AuthedIdentity, String>((
  ref,
  userId,
) async {
  final repo = ref.watch(profileRepositoryProvider);
  final profile = await repo.fetchProfile(userId);
  switch (profile.role) {
    case UserRole.dietitian:
      final detail = await repo.fetchDietitianDetail(userId);
      return AuthedIdentity(profile: profile, dietitianDetail: detail);
    case UserRole.client:
      final detail = await repo.fetchClientDetail(userId);
      return AuthedIdentity(profile: profile, clientDetail: detail);
    case UserRole.admin:
      return AuthedIdentity(profile: profile);
  }
});
