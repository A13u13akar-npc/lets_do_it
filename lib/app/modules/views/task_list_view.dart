import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/controllers/theme_controller.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/task_card.dart';
import 'package:lets_do_it/core/theme/theme_constants.dart';

class TaskListView extends GetView<TaskController> {
  const TaskListView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchTasks();
    });

    return Scaffold(
      key: controller.scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 36),
            onPressed: () => controller.scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 32),
              onPressed: () async {
                await Get.toNamed('/searchTasks');
                await controller.fetchTasks();
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: customPurple),
              child: Center(
                child: Text(
                  'Lets Do It 👊',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 45,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('Dark Mode'),
              trailing: Obx(
                    () => Switch(
                  value: themeController.isDarkMode.value,
                  onChanged: (_) => themeController.toggleTheme(),
                  activeThumbColor: customPurple,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello There 👋',
                style: Theme.of(Get.context!)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w400)),
            Text('Organize your plans for today',
                style: Theme.of(Get.context!)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(color: Colors.grey, thickness: 1),
            const SizedBox(height: 20),
            Text("Today's Tasks",
                style: Theme.of(Get.context!)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w400)),
            const SizedBox(height: 6),
            Text("💡 Tip: Swipe horizontally to complete or delete a task",
                style: Theme.of(Get.context!)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey, fontStyle: FontStyle.italic)),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final tasks = controller.tasks.toList()
                  ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet!', style: TextStyle(fontSize: 18)),
                  );
                }

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (_, index) {
                    final task = tasks[index];
                    return TaskCard(
                      taskKey: task.key,
                      onConfirmDismiss: () => Utils.confirmDialog(
                        title: "Please Confirm",
                        message: "This action can't be undone!",
                      ),
                      onDismissed: () async {
                        await controller.deleteTask(task);
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customPurple,
        onPressed: () async {
          final result = await Get.toNamed('/addTask');
          if (result == true) {
            await controller.fetchTasks();
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
