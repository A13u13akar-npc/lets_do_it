// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/controllers/theme_controller.dart';
import 'package:lets_do_it/app/widgets/task_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/core/theme/theme_constants.dart';

class TaskView extends StatefulWidget {
  const TaskView({super.key});

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  final TodoTaskController _controller = Get.find<TodoTaskController>();

  @override
  void initState() {
    super.initState();
    _loadSelectedTheme();
  }

  Future<void> _loadSelectedTheme() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getBool('isDarkMode');
    setState(() {
      _isDarkMode = savedTheme ?? false;
    });
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('MMM d, h:mm a');
    return formatter.format(date);
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Please Confirm"),
          content: const Text("This action cant be undo!"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("CANCEL"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text("COMPLETE"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeController themeController = Get.find<ThemeController>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.menu, size: 36),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 32),
              onPressed: () {
                Get.toNamed('/searchTasks');
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
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
                  onChanged: (value) {
                    themeController.toggleTheme();
                  },
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
            Text(
              'Hello There 👋',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w400),
            ),
            Text(
              'Organize your plans for today',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            const SizedBox(height: 20),
            Text(
              "Today's Tasks",
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 6),
            Text(
              "💡 Tip: Swipe horizontally to complete or delete a task",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                final List<TodoTask> allTasks = _controller.tasks.toList();
                allTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                if (allTasks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No tasks yet!',
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: allTasks.length,
                  itemBuilder: (context, index) {
                    final task = allTasks[index];
                    return TaskCard(
                      task: task,
                      onConfirmDismiss: () => _confirmDelete(context),
                      onDismissed: () async {
                        await _controller.deleteTask(task, context);
                        Utils().successToast("Task Completed!", context);
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
        onPressed: () {
          Get.toNamed('/addTask');
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
