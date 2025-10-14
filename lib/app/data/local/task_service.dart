import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/remote/remote_config_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TodoService {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();

  /// Deletes a task from the Hive box
  Future<void> deleteTask(TodoTask task, BuildContext context) async {
    try {
      await task.delete();
      Utils().successToast('Task marked as completed!', context);
    } catch (e) {
      Utils().failureToast('Failed to mark task as completed: $e', context);
    }
  }

  /// Adds or updates a task
  Future<void> addTask({
    required String title,
    String? description,
    required BuildContext context,
    required VoidCallback clearFormCallback,
  }) async {
    try {
      if (title.trim().isEmpty) {
        throw Exception('Task title cannot be empty');
      }

      final box = Hive.box<TodoTask>('tasks');
      final taskLimit = await _remoteConfigService.getTaskLimit();

      if (box.length >= taskLimit) {
        Get.toNamed('/pay');
        return;
      }

      final existingTask = box.values.firstWhere(
            (task) => task.title == title,
        orElse: () => TodoTask(title, description: '', createdAt: DateTime.now()),
      );

      if (existingTask.key != null && existingTask.title == title) {
        final confirmUpdate = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Update'),
              content: const Text(
                'A task with this title already exists. Do you want to update it?',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );

        if (confirmUpdate == true) {
          existingTask
            ..description = description
            ..createdAt = DateTime.now();
          await existingTask.save();

          Utils().successToast('Task updated successfully!', context);
          clearFormCallback();
        }
      } else {
        final task = TodoTask(
          title,
          description: description,
          createdAt: DateTime.now(),
        );

        await box.add(task);
        Utils().successToast('Task added successfully!', context);
        clearFormCallback();
      }
    } catch (e) {
      Utils().failureToast(e.toString(), context);
    }
  }
}
