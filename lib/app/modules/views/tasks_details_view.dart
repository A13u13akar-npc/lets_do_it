import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/task_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';

class TaskDetailsView extends StatefulWidget {
  const TaskDetailsView({super.key});

  @override
  State<TaskDetailsView> createState() => _TaskDetailsViewState();
}

class _TaskDetailsViewState extends State<TaskDetailsView> {
  final TodoService _todoService = TodoService();
  late TodoTask task;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    final args = Get.arguments;
    if (args is TodoTask) {
      task = args;
    } else {
      throw Exception('Invalid argument passed to TaskDetailsView');
    }

    _titleController = TextEditingController(text: task.title);
    _descriptionController = TextEditingController(
      text: task.description ?? '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _updateTask() async {
    FocusScope.of(context).unfocus();
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      task
        ..title = _titleController.text.trim()
        ..description = _descriptionController.text.trim()
        ..createdAt = DateTime.now();

      await task.save();
      Utils().successToast('Task updated successfully!', context);
      setState(() => _isEditing = false);
    } catch (e) {
      Utils().failureToast('Failed to update task: $e', context);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTask() async {
    FocusScope.of(context).unfocus();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _todoService.deleteTask(task, context);
      Utils().successToast('Task deleted successfully!', context);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat(
      'MMM d, yyyy • hh:mm a',
    ).format(task.createdAt);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details ℹ️'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
            onPressed: () {
              setState(() => _isEditing = !_isEditing);
            },
          ),
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteTask),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Hero(
                        tag: 'title_${task.key}',
                        child: Material(
                          color: Colors.transparent,
                          child: TextFormField(
                            controller: _titleController,
                            enabled: _isEditing,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Title',
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Title cannot be empty'
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (task.description != null &&
                          task.description!.trim().isNotEmpty)
                        Hero(
                          tag: 'desc_${task.key}',
                          child: Material(
                            color: Colors.transparent,
                            child: TextFormField(
                              controller: _descriptionController,
                              enabled: _isEditing,
                              maxLines: 3,
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              decoration: const InputDecoration(
                                labelText: 'Description',
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 30),
                      Hero(
                        tag: 'time_${task.key}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            'Created: $formattedDate',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isEditing)
                ExpandedButton(
                  text: _isLoading ? 'Updating...' : 'Update Task',
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      await _updateTask();
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
