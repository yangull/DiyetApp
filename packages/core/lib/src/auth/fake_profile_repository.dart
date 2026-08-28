import 'models.dart';
import 'profile_repository.dart';

/// In-memory stand-in for tests. Seed it before use — [fetchProfile] and
/// friends throw [StateError] for an unknown id, the same way a missing row
/// would surface from Supabase.
class FakeProfileRepository implements ProfileRepository {
  final _profiles = <String, AppProfile>{};
  final _dietitians = <String, DietitianDetail>{};
  final _clients = <String, ClientDetail>{};

  void seedClient(String userId, {String fullName = 'Test Danışan'}) {
    _profiles[userId] = AppProfile(
      id: userId,
      role: UserRole.client,
      fullName: fullName,
    );
    _clients[userId] = ClientDetail(userId: userId);
  }

  void seedDietitian(
    String userId, {
    String fullName = 'Test Diyetisyen',
    VerificationStatus status = VerificationStatus.pending,
  }) {
    _profiles[userId] = AppProfile(
      id: userId,
      role: UserRole.dietitian,
      fullName: fullName,
    );
    _dietitians[userId] = DietitianDetail(
      userId: userId,
      specialties: const [],
      verificationStatus: status,
    );
  }

  /// Lets a test simulate the dietitian getting approved between two
  /// "Durumu Yenile" presses.
  void setVerificationStatus(String userId, VerificationStatus status) {
    final current = _dietitians[userId];
    if (current == null) throw StateError('No seeded dietitian: $userId');
    _dietitians[userId] = DietitianDetail(
      userId: userId,
      specialties: current.specialties,
      verificationStatus: status,
      certificateUrl: current.certificateUrl,
      bio: current.bio,
    );
  }

  @override
  Future<AppProfile> fetchProfile(String userId) async {
    final profile = _profiles[userId];
    if (profile == null) throw StateError('No seeded profile: $userId');
    return profile;
  }

  @override
  Future<DietitianDetail> fetchDietitianDetail(String userId) async {
    final detail = _dietitians[userId];
    if (detail == null) throw StateError('No seeded dietitian: $userId');
    return detail;
  }

  @override
  Future<ClientDetail> fetchClientDetail(String userId) async {
    final detail = _clients[userId];
    if (detail == null) throw StateError('No seeded client: $userId');
    return detail;
  }
}
