import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _remoteConfig.setDefaults(<String, dynamic>{
      'max_free_tasks': 2,
      'toggle_reward_task_ad': false,
    });
  }

  static Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      return false;
    }
  }

  static Future<int> getTaskLimit() async {
    await initialize();
    await fetchAndActivate();
    return _remoteConfig.getInt('max_free_tasks');
  }

  static Future<bool> getToggleRewardTaskAd() async {
    await fetchAndActivate();
    return _remoteConfig.getBool('toggle_reward_task_ad');
  }
}
