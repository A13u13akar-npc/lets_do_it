import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Logs a custom event with optional parameters
  Future<void> logEvent({
    required String eventName,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: eventName, parameters: parameters);
  }

  /// Logs when the "Create Task" button is tapped
  Future<void> logCreateTaskButtonTap() async {
    await logEvent(
      eventName: 'create_task_button_tapped',
      parameters: {'timestamp': DateTime.now().toIso8601String()},
    );
  }
}
