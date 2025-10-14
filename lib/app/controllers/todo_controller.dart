import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:flutter/material.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TodoTaskController extends GetxController {
  final RxList<TodoTask> tasks = <TodoTask>[].obs;
  late Box<TodoTask> _taskBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _taskBox = Hive.box<TodoTask>('tasks');
    // Load existing tasks
    tasks.assignAll(_taskBox.values.toList());

    // Listen for Hive box updates automatically
    _taskBox.watch().listen((event) {
      tasks.assignAll(_taskBox.values.toList());
    });
  }

  Future<void> addTask({
    required String title,
    String? description,
    required BuildContext context,
  }) async {
    if (title.trim().isEmpty) {
      Utils().failureToast('Title cannot be empty', context);
      return;
    }

    final existingTask = _taskBox.values.firstWhere(
          (task) => task.title == title,
      orElse: () => TodoTask(''),
    );

    if (existingTask.title.isNotEmpty) {
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Update'),
          content: const Text('A task with this title already exists. Update it?'),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('Cancel')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('Update')),
          ],
        ),
      );

      if (confirm == true) {
        existingTask
          ..description = description
          ..createdAt = DateTime.now();
        await existingTask.save();
        Utils().failureToast('Task updated successfully!', context);
      }
    } else {
      final task = TodoTask(
        title,
        description: description,
        createdAt: DateTime.now(),
      );
      await _taskBox.add(task);
      Utils().failureToast('Task added successfully!', context);
    }
  }

  Future<void> deleteTask(TodoTask task) async {
    await task.delete();
    tasks.remove(task);
  }
}
