/// Mirrors `public.user_role` in the first migration. Values match the
/// Postgres enum labels exactly, so `name` round-trips through Supabase.
enum UserRole { client, dietitian, admin }

/// Mirrors `public.verification_status`.
enum VerificationStatus { pending, approved, rejected }

/// A signed-in Supabase user, independent of any Supabase type. Kept separate
/// from [AppProfile] because it is known the instant a session exists, before
/// the `profiles` row has been fetched.
class AuthSession {
  const AuthSession({required this.userId, required this.email});

  final String userId;
  final String email;
}

/// Mirrors `public.profiles`. `role` is immutable once the signup trigger
/// writes it (PLANNING.md §2.2 #32) — nothing in this app ever changes it.
class AppProfile {
  const AppProfile({
    required this.id,
    required this.role,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final UserRole role;
  final String fullName;
  final String? avatarUrl;
}

/// Mirrors `public.dietitians`. Only fetched for a signed-in dietitian.
class DietitianDetail {
  const DietitianDetail({
    required this.userId,
    required this.specialties,
    required this.verificationStatus,
    this.certificateUrl,
    this.bio,
  });

  final String userId;
  final List<String> specialties;
  final VerificationStatus verificationStatus;
  final String? certificateUrl;
  final String? bio;
}

/// Mirrors `public.clients`. Only fetched for a signed-in client.
class ClientDetail {
  const ClientDetail({
    required this.userId,
    this.goal,
    this.budgetRange,
    this.healthNotes,
  });

  final String userId;
  final String? goal;
  final String? budgetRange;
  final String? healthNotes;
}

/// What [AuthGate] hands to the screen once a session, a matching-role
/// profile, and (for a dietitian) the verification status are all known.
/// Exactly one of [dietitianDetail] / [clientDetail] is set, matching
/// [profile.role].
class AuthedIdentity {
  const AuthedIdentity({
    required this.profile,
    this.dietitianDetail,
    this.clientDetail,
  });

  final AppProfile profile;
  final DietitianDetail? dietitianDetail;
  final ClientDetail? clientDetail;
}
