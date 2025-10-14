import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  /// Initialize remote config defaults
  Future<void> initialize() async {
    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: Duration.zero, // force fresh fetch (for testing)
      ),
    );

    await _remoteConfig.setDefaults(<String, dynamic>{
      'max_free_tasks': 2, // fallback default
    });
  }

  /// Fetch latest config values from Firebase
  Future<bool> fetchAndActivate() async {
    try {
      return await _remoteConfig.fetchAndActivate();
    } catch (e) {
      return false;
    }
  }

  /// Get max free tasks limit
  Future<int> getTaskLimit() async {
    await initialize();
    await fetchAndActivate();
    final limit = _remoteConfig.getInt('max_free_tasks');
    return limit;
  }

  /// Get value by key (for other future use cases)
  String getString(String key) => _remoteConfig.getString(key);
  int getInt(String key) => _remoteConfig.getInt(key);
  bool getBool(String key) => _remoteConfig.getBool(key);
}
