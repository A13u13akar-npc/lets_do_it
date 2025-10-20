import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/services/gemini_services.dart';
import 'package:lets_do_it/app/data/services/task_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TaskController extends GetxController {
  final TaskService _service = TaskService();

  RxList<TodoTask> get tasks => _service.tasks;
  final RxBool isGenerating = false.obs;
  final RxBool isCreatingTask = false.obs;
  final RxString generatedTitle = ''.obs;
  final RxString generatedDescription = ''.obs;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final filteredTasks = <TodoTask>[].obs;
  final RxBool isLoading = false.obs;
  final isEditing = false.obs;
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final Rx<TodoTask?> selectedTask = Rx<TodoTask?>(null);

  @override
  void onInit() {
    super.onInit();
    _service.init();
  }

  @override
  void onClose() {
    super.onClose();
    titleController.clear();
    descriptionController.clear();
  }

  Future<void> generateWithAI() async {
    isGenerating.value = true;
    try {
      final result = await GeminiService.generateTask();
      generatedTitle.value = result['title'] ?? '';
      generatedDescription.value = result['description'] ?? '';
    } catch (e) {
      Utils().failureToast('AI generation failed: $e', Get.context!);
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> addTask({
    required String title,
    required String description,
    required VoidCallback clearFormCallback,
  }) async {
    if (isCreatingTask.value || isGenerating.value) return;
    isCreatingTask.value = true;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await _service.addTask(
        title: title,
        description: description,
        context: Get.context!,
        clearFormCallback: clearFormCallback,
      );
      await fetchTasks();
      Get.back(result: true);
    } catch (e) {
      Utils().failureToast(e.toString(), Get.context!);
    } finally {
      isCreatingTask.value = false;
    }
  }

  Future<void> searchTasks(String query) async {
    final tasks = await _service.searchTasks(query);
    filteredTasks.assignAll(tasks.reversed);
  }

  void setSelectedTask(TodoTask task) {
    selectedTask.value = task;
    titleController.text = task.title;
    descriptionController.text = task.description ?? '';
  }

  Future<void> updateTask() async {
    FocusScope.of(Get.context!).unfocus();
    if (isLoading.value) return;

    isLoading.value = true;
    try {
      final task = selectedTask.value;
      if (task == null) return;

      task
        ..title = titleController.text.trim()
        ..description = descriptionController.text.trim()
        ..createdAt = DateTime.now();

      await task.save();
      Utils().successToast('Task updated successfully!', Get.context!);
      isEditing.value = false;
      await fetchTasks();
    } catch (e) {
      Utils().failureToast('Failed to update task: $e', Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTask(TodoTask task) async {
    try {
      await _service.deleteTask(task, Get.context!);
      await fetchTasks();
      Utils().successToast("Task Completed!", Get.context!);
    } catch (e) {
      Utils().failureToast("Failed to delete: $e", Get.context!);
    }
  }

  void clearForm() {
    titleController.clear();
    descriptionController.clear();
  }

  Future<void> fetchTasks() async {
    try {
      await _service.fetchTasks();
    } catch (e) {
      Utils().failureToast('Failed to fetch tasks: $e', Get.context!);
    }
  }
}
