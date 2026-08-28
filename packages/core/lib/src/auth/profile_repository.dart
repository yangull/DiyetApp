import 'models.dart';

/// Reads for the three identity tables. The signup trigger guarantees a
/// `profiles` row and exactly one detail row exist by the time any of these
/// are called for a real user, so all three throw rather than return null on
/// a missing row — that would mean the trigger didn't run, which is a bug to
/// surface, not a state to model.
abstract class ProfileRepository {
  Future<AppProfile> fetchProfile(String userId);

  Future<DietitianDetail> fetchDietitianDetail(String userId);

  Future<ClientDetail> fetchClientDetail(String userId);
}
