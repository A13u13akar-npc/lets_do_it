import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/gemini_controller.dart';

class GeminiBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GeminiController());
  }
}
