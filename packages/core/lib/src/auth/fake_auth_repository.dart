import 'dart:async';

import 'auth_repository.dart';
import 'models.dart';

/// In-memory stand-in for tests and any screen work that shouldn't need a
/// live Supabase project. Signup always succeeds and signs the user in
/// immediately — there is no email confirmation step in this slice (§2.2 #21).
class FakeAuthRepository implements AuthRepository {
  AuthSession? _session;
  var _nextId = 1;
  final _controller = StreamController<AuthSession?>.broadcast();

  // A broadcast stream never replays to a new listener, but AuthGate always
  // subscribes after signIn()/signUp() have already been called in a test
  // setup — so without a replay, the very first widget build would see
  // nothing and stay stuck signed out. Supabase's real onAuthStateChange
  // does replay the current session to each new listener; this matches that.
  @override
  Stream<AuthSession?> get sessionChanges async* {
    yield _session;
    yield* _controller.stream;
  }

  @override
  AuthSession? get currentSession => _session;

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    bool asDietitian = false,
  }) async {
    _session = AuthSession(userId: 'fake-user-${_nextId++}', email: email);
    _controller.add(_session);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _session = AuthSession(userId: 'fake-user-${_nextId++}', email: email);
    _controller.add(_session);
  }

  @override
  Future<void> signOut() async {
    _session = null;
    _controller.add(null);
  }
}
