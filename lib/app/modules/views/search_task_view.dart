import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/widgets/task_card.dart';
import 'package:lets_do_it/app/data/services/task_service.dart';

class SearchTaskView extends StatefulWidget {
  const SearchTaskView({super.key});

  @override
  State<SearchTaskView> createState() => _SearchTaskViewState();
}

class _SearchTaskViewState extends State<SearchTaskView> {
  final taskService = TaskService();
  final searchController = TextEditingController();
  final focusNode = FocusNode();
  final taskController = Get.find<TaskController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      FocusScope.of(Get.context!).requestFocus(focusNode);
      await taskController.fetchTasks();
      await taskController.searchTasks('');
    });
  }

  Future<bool?> confirmDelete() {
    return showDialog<bool>(
      context: Get.context!,
      builder: (_) => AlertDialog(
        title: const Text("Please Confirm"),
        content: const Text("This action can’t be undone!"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text("CANCEL"),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text("COMPLETE"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: searchController,
          focusNode: focusNode,
          onChanged: (value) async {
            await taskController.searchTasks(value);
          },
          decoration: InputDecoration(
            hintText: 'Search tasks...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey.shade500),
          ),
          style: const TextStyle(fontSize: 18),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () async {
              searchController.clear();
              await taskController.searchTasks('');
              FocusScope.of(context).requestFocus(focusNode);
            },
          ),
        ],
      ),
      body: Obx(() {
        final tasks = taskController.filteredTasks;
        if (tasks.isEmpty) {
          return const Center(
            child: Text('No tasks found', style: TextStyle(fontSize: 16)),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await taskController.fetchTasks();
            await taskController.searchTasks(searchController.text);
          },
          child: ListView.builder(
            padding: const EdgeInsets.only(left: 8.0, top: 8.0),
            itemCount: tasks.length,
            itemBuilder: (_, index) {
              final task = tasks[index];
              return TaskCard(
                task: task,
                onConfirmDismiss: confirmDelete,
                onDismissed: () async {
                  await taskController.deleteTask(task);
                  await taskController.searchTasks(searchController.text);
                },
              );
            },
          ),
        );
      }),
    );
  }
}
