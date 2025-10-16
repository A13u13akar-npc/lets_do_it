import 'package:get/get.dart';
import 'package:lets_do_it/app/data/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _analyticsService = AnalyticsService();

  Future<void> logEvent(String eventName, {Map<String, Object>? parameters}) async {
    await _analyticsService.logEvent(eventName: eventName, parameters: parameters);
  }

  Future<void> logCreateTaskButtonTap() async {
    await _analyticsService.logCreateTaskButtonTap();
  }
}
