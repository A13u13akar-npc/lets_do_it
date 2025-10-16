import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero,
      ),
    );

    await _remoteConfig.setDefaults(<String, dynamic>{'max_free_tasks': 2});
  }

  Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      return false;
    }
  }

  Future<int> getTaskLimit() async {
    await initialize();
    await fetchAndActivate();
    final limit = _remoteConfig.getInt('max_free_tasks');
    return limit;
  }

  Future<bool> getToggleRewardTaskAd() async {
    await fetchAndActivate();
    return _remoteConfig.getBool('toggle_reward_task_ad');
  }
}
