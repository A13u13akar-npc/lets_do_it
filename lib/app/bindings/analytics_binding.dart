import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/analytics_controller.dart';

class AnalyticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AnalyticsController>(() => AnalyticsController());
  }
}
