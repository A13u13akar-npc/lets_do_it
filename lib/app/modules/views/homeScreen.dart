import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lets_do_it/app/data/model/services.dart';
import 'package:lets_do_it/app/data/model/todoModel.dart';
import 'package:lets_do_it/app/modules/views/addTaskScreen.dart';
import 'package:lets_do_it/app/utils/taskTile.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/core/theme/theme.dart';
import 'package:lets_do_it/core/theme/themeProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SharedPreferences _prefs;
  bool _isDarkMode = false;
  final TodoService _todoService = TodoService();

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

  void _toggleTaskCompletion(TodoTask task) {
    task.isCompleted = !task.isCompleted;
    task.save(); // Save the task back to Hive after updating
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.menu,
                  size: 36,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.search, size: 32),
              onPressed: () {
                // Implement search functionality here
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello There 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
            Text(
              'Organize your plans for today',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey,
                  ),
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder<Box<TodoTask>>(
                valueListenable: Hive.box<TodoTask>('tasks').listenable(),
                builder: (context, box, _) {
                  if (!box.isOpen) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  List<TodoTask> allTasks = box.values.toList();
                  // Sort tasks by start time in ascending order
                  allTasks.sort((a, b) => a.startTime.compareTo(b.startTime));

                  if (allTasks.isEmpty) {
                    return const Center(
                      child: Text(
                        'No tasks for today!',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: allTasks.length,
                    itemBuilder: (context, index) {
                      final task = allTasks[index];
                      return Dismissible(
                        key: Key(task.key.toString()),
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text("Confirm"),
                                content: const Text(
                                    "Are you sure you want to delete this task?"),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text("CANCEL"),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text("DELETE"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        onDismissed: (direction) async {
                          await _todoService.deleteTask(task);
                        },
                        child: TodoListTile(
                          task: task,
                          onCompleted: () {
                            _toggleTaskCompletion(task);
                          },
                          onDelete: () async {
                            await _todoService.deleteTask(task);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: customPurple,
        onPressed: () {
          Utils().pushSlideTransition(context, CreateTaskScreen());
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: customPurple,
              ),
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
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) async {
                  setState(() {
                    _isDarkMode = value;
                  });
                  final themeProvider = Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  );
                  themeProvider.toggleTheme();
                  await _prefs.setBool('isDarkMode', value);
                },
                activeThumbColor: customPurple,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
