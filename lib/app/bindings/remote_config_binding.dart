import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/remote_config_controller.dart';

class RemoteConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => RemoteConfigController());
  }
}
