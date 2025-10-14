import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/todo_controller.dart';

class TodoBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TodoTaskController>(() => TodoTaskController());
  }
}
