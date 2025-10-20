import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/services/remote_config_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TaskService {
  final RxList<TodoTask> tasks = <TodoTask>[].obs;
  Box<TodoTask>? _box;

  Future<void> init() async {
    _box = await getTaskBox();
    tasks.assignAll(_box!.values.toList());
  }

  Future<Box<TodoTask>> getTaskBox() async {
    if (!Hive.isBoxOpen('tasks')) {
      await Hive.openBox<TodoTask>('tasks');
    }
    return Hive.box<TodoTask>('tasks');
  }

  Future<void> deleteTask(TodoTask task) async {
      await task.delete();
  }

  Future<void> addTask({
    required String title,
    String? description,
    required VoidCallback clearFormCallback,
    bool ignoreLimit = false,
  }) async {
    try {
      if (title.trim().isEmpty) throw Exception('Task title cannot be empty');

      final box = Hive.box<TodoTask>('tasks');
      final taskLimit = ignoreLimit
          ? null
          : await RemoteConfigService.getTaskLimit();

      if (!ignoreLimit && box.length >= (taskLimit ?? 0)) {
        if (Get.currentRoute != '/watchAd') {
          Get.toNamed(
            '/watchAd',
            arguments: {'title': title, 'description': description},
          );
        }
        return;
      }

      final existingTask = box.values.firstWhere(
        (task) => task.title == title,
        orElse: () =>
            TodoTask(title, description: '', createdAt: DateTime.now()),
      );

      if (existingTask.key != null && existingTask.title == title) {
        final confirmUpdate = await showDialog<bool>(
          context: Get.context!,
          builder: (_) => AlertDialog(
            title: const Text('Confirm Update'),
            content: const Text('Task exists. Update it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(Get.context!, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(Get.context!, true),
                child: const Text('Update'),
              ),
            ],
          ),
        );

        if (confirmUpdate == true) {
          existingTask
            ..description = description
            ..createdAt = DateTime.now();
          await existingTask.save();
          Utils().successToast('Task updated successfully!', Get.context!);
          clearFormCallback();
        }
      } else {
        final task = TodoTask(
          title,
          description: description,
          createdAt: DateTime.now(),
        );
        await box.add(task);
        Utils().successToast('Task added successfully!', Get.context!);
        clearFormCallback();
      }
    } catch (e) {
      Utils().failureToast(e.toString(), Get.context!);
    }
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
      final descMatch = (task.description ?? '').toLowerCase().contains(
        lowerQuery,
      );
      final dateMatch = dateFormats
          .map((f) => f.format(task.createdAt).toLowerCase())
          .any((formatted) => formatted.contains(lowerQuery));
      return titleMatch || descMatch || dateMatch;
    }).toList();
  }

  Future<void> fetchTasks() async {
    final box = await getTaskBox();
    tasks.assignAll(box.values.toList());
  }
}
