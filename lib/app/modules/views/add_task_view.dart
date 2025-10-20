import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/controllers/theme_controller.dart';
import 'package:lets_do_it/app/data/services/analytics_service.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddTaskView extends StatelessWidget {
  const AddTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    final theme = Theme.of(context);
    final formKey = GlobalKey<FormState>();
    final taskController = Get.find<TaskController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      taskController.clearForm();
    });

    return PopScope(
      onPopInvokedWithResult: (value, direction) async {
        taskController.clearForm();
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Add Tasks 😼')),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Add Task',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Obx(
                              () => IconButton(
                                onPressed: taskController.isGenerating.value
                                    ? null
                                    : () => taskController.generateWithAI(),
                                icon: const Icon(Icons.auto_awesome),
                                tooltip: 'Generate with AI',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Obx(() {
                          ever(taskController.generatedTitle, (value) {
                            if (value.isNotEmpty) {
                              taskController.titleController.text = value;
                            }
                          });
                          ever(taskController.generatedDescription, (value) {
                            if (value.isNotEmpty) {
                              taskController.descriptionController.text = value;
                            }
                          });
                          return Column(
                            children: [
                              Skeletonizer(
                                enabled: taskController.isGenerating.value,
                                child: TextFormField(
                                  controller: taskController.titleController,
                                  decoration: InputDecoration(
                                    labelText: 'Task Title *',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: themeController.isDarkMode.value
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade200,
                                    contentPadding: const EdgeInsets.all(18),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter a task title';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 20),
                              Skeletonizer(
                                enabled: taskController.isGenerating.value,
                                child: TextFormField(
                                  controller:
                                      taskController.descriptionController,
                                  decoration: InputDecoration(
                                    labelText: 'Description (optional)',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: themeController.isDarkMode.value
                                        ? Colors.grey.shade900
                                        : Colors.grey.shade200,
                                    contentPadding: const EdgeInsets.all(18),
                                  ),
                                  maxLines: 3,
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Obx(() {
                  return ExpandedButton(
                    text: taskController.isCreatingTask.value
                        ? 'Creating...'
                        : 'Create Task',
                    onPressed: () {
                      if (taskController.isCreatingTask.value ||
                          taskController.isGenerating.value) {
                        return;
                      }
                      if (formKey.currentState?.validate() == true) {
                        AnalyticsService.logCreateTaskButtonTap();
                        taskController.addTask(
                          title: taskController.titleController.text,
                          description:
                              taskController.descriptionController.text,
                          clearFormCallback: taskController.clearForm,
                        );
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
