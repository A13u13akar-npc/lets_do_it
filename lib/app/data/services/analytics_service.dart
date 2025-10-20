import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  static Future<void> logEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  static Future<void> logCreateTaskButtonTap() async {
    await logEvent(
      eventName: 'create_task_button_tapped',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}
