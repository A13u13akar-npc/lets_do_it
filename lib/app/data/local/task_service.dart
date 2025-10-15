import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/controllers/remote_config_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TodoService {
  final RemoteConfigController _remoteConfigController = Get.find<RemoteConfigController>();

  Future<void> deleteTask(TodoTask task, BuildContext context) async {
    try {
      await task.delete();
    } catch (e) {
      Utils().failureToast('Failed to eliminate the task: $e', context);
    }
  }

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
      final taskLimit = _remoteConfigController.taskLimit;

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

  Future<Box<TodoTask>> getTaskBox() async {
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<TodoTask>('tasks');
    }
    return Hive.box<TodoTask>('tasks');
  }

  Future<List<TodoTask>> searchTasks(String query) async {
    final box = await getTaskBox();
    if (query.trim().isEmpty) return box.values.toList();

    final lowerQuery = query.toLowerCase();
    final dateFormats = [
      DateFormat('MMM d, yyyy – h:mm a'),
      DateFormat('MMM d, yyyy'),
      DateFormat('MMM d'),
      DateFormat('yyyy-MM-dd'),
      DateFormat('dd/MM/yyyy'),
      DateFormat('h:mm a'),
    ];

    return box.values.where((task) {
      final titleMatch = task.title.toLowerCase().contains(lowerQuery);
      final descMatch = (task.description ?? '').toLowerCase().contains(lowerQuery);
      final dateStrings = dateFormats.map((f) => f.format(task.createdAt).toLowerCase()).toList();
      final dateMatch = dateStrings.any((formatted) => formatted.contains(lowerQuery));

      return titleMatch || descMatch || dateMatch;
    }).toList();
  }
}
