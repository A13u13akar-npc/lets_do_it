import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';

class TaskDetailsView extends StatelessWidget {
  const TaskDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    final task = Get.arguments;
    taskController.setSelectedTask(task);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details ℹ️'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(
                taskController.isEditing.value ? Icons.close : Icons.edit),
            onPressed: () {
              taskController.isEditing.toggle();
            },
          )),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content: const Text("Are you sure you want to delete this task?"),
                  actions: [
                    TextButton(onPressed: () => Get.back(result: false), child: const Text("CANCEL")),
                    TextButton(onPressed: () => Get.back(result: true), child: const Text("DELETE")),
                  ],
                ),
              );

              if (confirm == true) {
                await taskController.deleteTask(task);
                Get.back(closeOverlays: true);
              }
            },
          ),

        ],
      ),
      body: Obx(() {
        final t = taskController.selectedTask.value;
        if (t == null) return const SizedBox();

        final formattedDate =
        DateFormat('MMM d, yyyy • hh:mm a').format(t.createdAt);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Padding(
          padding: const EdgeInsets.all(18.0),
          child: Form(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'title_${t.key}',
                          child: Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: taskController.titleController,
                              enabled: taskController.isEditing.value,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration:
                              const InputDecoration(labelText: 'Title'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Hero(
                          tag: 'desc_${t.key}',
                          child: Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: taskController.descriptionController,
                              enabled: taskController.isEditing.value,
                              maxLines: 3,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration:
                              const InputDecoration(labelText: 'Description'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Hero(
                          tag: 'time_${t.key}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              'Created: $formattedDate',
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (taskController.isEditing.value)
                  ExpandedButton(
                    text: taskController.isLoading.value
                        ? 'Updating...'
                        : 'Update Task',
                    onPressed: () => taskController.updateTask(),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
