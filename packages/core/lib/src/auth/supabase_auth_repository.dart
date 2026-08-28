import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'auth_repository.dart';
import 'models.dart';

AuthSession? _toSession(sb.Session? session) {
  final user = session?.user;
  if (user == null) return null;
  return AuthSession(userId: user.id, email: user.email ?? '');
}

class SupabaseAuthRepository implements AuthRepository {
  sb.GoTrueClient get _auth => sb.Supabase.instance.client.auth;

  @override
  Stream<AuthSession?> get sessionChanges =>
      _auth.onAuthStateChange.map((event) => _toSession(event.session));

  @override
  AuthSession? get currentSession => _toSession(_auth.currentSession);

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    bool asDietitian = false,
  }) async {
    // The signup trigger (handle_new_user) only honors 'dietitian' here and
    // turns everything else into 'client' — this metadata is a request, not
    // a grant (PLANNING.md §2.2 #32).
    await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, if (asDietitian) 'role': 'dietitian'},
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithPassword(email: email, password: password);

  @override
  Future<void> signOut() => _auth.signOut();
}
