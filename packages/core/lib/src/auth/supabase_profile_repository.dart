import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'models.dart';
import 'profile_repository.dart';

UserRole _parseRole(String value) =>
    UserRole.values.firstWhere((r) => r.name == value);

VerificationStatus _parseVerification(String value) =>
    VerificationStatus.values.firstWhere((v) => v.name == value);

class SupabaseProfileRepository implements ProfileRepository {
  sb.SupabaseClient get _db => sb.Supabase.instance.client;

  @override
  Future<AppProfile> fetchProfile(String userId) async {
    final row = await _db
        .from('profiles')
        .select('id, role, full_name, avatar_url')
        .eq('id', userId)
        .single();
    return AppProfile(
      id: row['id'] as String,
      role: _parseRole(row['role'] as String),
      fullName: row['full_name'] as String,
      avatarUrl: row['avatar_url'] as String?,
    );
  }

  @override
  Future<DietitianDetail> fetchDietitianDetail(String userId) async {
    final row = await _db
        .from('dietitians')
        .select(
          'user_id, specialties, certificate_url, verification_status, bio',
        )
        .eq('user_id', userId)
        .single();
    return DietitianDetail(
      userId: row['user_id'] as String,
      specialties: List<String>.from(row['specialties'] as List),
      verificationStatus: _parseVerification(
        row['verification_status'] as String,
      ),
      certificateUrl: row['certificate_url'] as String?,
      bio: row['bio'] as String?,
    );
  }

  @override
  Future<ClientDetail> fetchClientDetail(String userId) async {
    final row = await _db
        .from('clients')
        .select('user_id, goal, budget_range, health_notes')
        .eq('user_id', userId)
        .single();
    return ClientDetail(
      userId: row['user_id'] as String,
      goal: row['goal'] as String?,
      budgetRange: row['budget_range'] as String?,
      healthNotes: row['health_notes'] as String?,
    );
  }
}
