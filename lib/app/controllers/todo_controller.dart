import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/local/task_service.dart';

class TodoTaskController extends GetxController {
  final TodoService _todoService = TodoService();
  final RxList<TodoTask> tasks = <TodoTask>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadTasks();
  }


  Future<void> _loadTasks() async {
    final box = await _todoService.getTaskBox();
    tasks.assignAll(box.values.toList());
    box.watch().listen((_) => tasks.assignAll(box.values.toList()));
  }

  Future<void> addTask({
    required String title,
    String? description,
    required BuildContext context,
    required VoidCallback clearFormCallback,
  }) async {
    await _todoService.addTask(
      title: title,
      description: description,
      context: context,
      clearFormCallback: clearFormCallback,
    );
  }

  Future<void> deleteTask(TodoTask task, BuildContext context) async {
    await _todoService.deleteTask(task, context);
    tasks.remove(task);
  }
}
