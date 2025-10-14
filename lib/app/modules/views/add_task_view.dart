import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lets_do_it/app/data/analytics/analytics_service.dart';
import 'package:lets_do_it/app/data/local/task_service.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  _AddTaskViewState createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final TodoService _todoService = TodoService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _title = '';
  String? _description;
  bool _isLoading = false; // 👈 loading flag

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  @override
  void dispose() {
    if (Get.isRegistered<AddTaskView>()) {
      Get.delete<AddTaskView>();
    }
    super.dispose();
  }

  Future<void> _openBox() async {
    await Hive.openBox<TodoTask>('tasks');
  }

  Future<void> _addTask() async {
    FocusScope.of(context).unfocus();

    if (_isLoading) return; // prevent duplicate taps
    setState(() => _isLoading = true); // 👈 start loading
    try {
      await _todoService.addTask(
        title: _title,
        description: _description,
        context: context,
        clearFormCallback: _clearForm,
      );
    } catch (e) {
      Utils().failureToast(e.toString(), context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false); // 👈 stop loading
      }
    }
  }

  void _clearForm() {
    setState(() {
      _title = '';
      _description = '';
    });
    _formKey.currentState?.reset();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Add Tasks 😼')),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Add Task',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Task Title *',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        onChanged: (value) => _title = value,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade200,
                          contentPadding: const EdgeInsets.all(18),
                        ),
                        maxLines: 3,
                        onChanged: (value) => _description = value,
                      ),
                    ],
                  ),
                ),
              ),
              ExpandedButton(
                text: _isLoading ? 'Creating...' : 'Create Task',
                onPressed: () async{
                  await AnalyticsService().logCreateTaskButtonTap();

                  if (_isLoading) return;
                  if (_formKey.currentState?.validate() == true) {
                    _addTask();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
