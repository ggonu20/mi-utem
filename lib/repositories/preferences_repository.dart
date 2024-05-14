import 'package:get_storage/get_storage.dart';
import 'package:mi_utem/config/logger.dart';
import 'package:mi_utem/config/secure_storage.dart';

class PreferencesRepository {
  static const aliasKey = 'apodo';
  static const lastLoginKey = 'ultimo_login';
  static const onboardingStepKey = 'paso_onboarding';
  static GetStorage _storage = GetStorage('MiUTEM_Preferences');

  Future<bool> hasAlias() async => await secureStorage.containsKey(key: aliasKey);

  Future<void> setAlias(String? alias) async => await secureStorage.write(key: aliasKey, value: alias);

  Future<String?> getAlias() async => await secureStorage.read(key: aliasKey);

  Future<bool> hasLastLogin() async => await secureStorage.containsKey(key: lastLoginKey);

  Future<void> setLastLogin(DateTime? lastLogin) async => await secureStorage.write(key: lastLoginKey, value: lastLogin?.toString());

  Future<DateTime?> getLastLogin() async {
    final lastLogin = await secureStorage.read(key: lastLoginKey);
    logger.d("Last login $lastLogin");
    return lastLogin != null ? DateTime.tryParse(lastLogin) : null;
  }

  Future<bool> hasCompletedOnboarding() async => await secureStorage.containsKey(key: onboardingStepKey) && await getOnboardingStep() == 'complete';

  Future<void> setOnboardingStep(String? step) async => await secureStorage.write(key: onboardingStepKey, value: step);

  Future<String?> getOnboardingStep() async => await secureStorage.read(key: onboardingStepKey);

  Future<bool> hasProfilePicture() async => _storage.hasData("profile_photo");

  Future<void> setProfilePicture(String? photo) async => await _storage.write("profile_photo", photo);

  Future<String?> getProfilePicture() async => _storage.read("profile_photo");

}