import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(() => TaskController(), fenix: true);
  }
}
