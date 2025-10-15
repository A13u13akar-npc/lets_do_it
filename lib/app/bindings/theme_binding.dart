import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/theme_controller.dart';

class ThemeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ThemeController>(() => ThemeController());
  }
}
