import 'models.dart';

/// Sign-up, sign-in and session state. No profile data lives here — that is
/// [ProfileRepository]'s job, fetched only once a session exists.
///
/// `asDietitian` is the only role signal ([PLANNING.md] §2.3 #37): the client
/// app never sets it, the dietitian panel always does. The signup trigger
/// re-derives the role server-side regardless (§2.2 #32) — this flag is a
/// request, not a grant.
abstract class AuthRepository {
  /// Null once at startup before Supabase reports the initial session, then
  /// every value after including nulls (signed out).
  Stream<AuthSession?> get sessionChanges;

  AuthSession? get currentSession;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    bool asDietitian = false,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();
}
