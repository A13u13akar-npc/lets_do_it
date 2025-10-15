import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lets_do_it/app/data/analytics/analytics_service.dart';
import 'package:lets_do_it/app/data/gemini/gemini_services.dart';
import 'package:lets_do_it/app/data/local/task_service.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class AddTaskView extends StatefulWidget {
  const AddTaskView({super.key});

  @override
  State<AddTaskView> createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  final TodoService _todoService = TodoService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _isLoading = false;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    await Hive.openBox<TodoTask>('tasks');
  }

  Future<void> _addTask() async {
    FocusScope.of(context).unfocus();
    if (_isLoading || _isGenerating) return;
    setState(() => _isLoading = true);
    try {
      await _todoService.addTask(
        title: _titleController.text,
        description: _descriptionController.text,
        context: context,
        clearFormCallback: _clearForm,
      );
    } catch (e) {
      Utils().failureToast(e.toString(), context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _generateTask() async {
    setState(() => _isGenerating = true);

    try {
      final task = await GeminiService().generateTask();
      setState(() {
        _titleController.text = task['title'] ?? '';
        _descriptionController.text = task['description'] ?? '';
      });
    } catch (e) {
      Utils().failureToast('Error generating task: $e', context);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Task',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            onPressed: _isGenerating ? null : _generateTask,
                            icon: const Icon(Icons.auto_awesome),
                            tooltip: 'Generate with AI',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Skeletonizer(
                            enabled: _isGenerating,
                            child: TextFormField(
                              controller: _titleController,
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
                            ),
                          ),
                          const SizedBox(height: 20),
                          Skeletonizer(
                            enabled: _isGenerating,
                            child: TextFormField(
                              controller: _descriptionController,
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
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ExpandedButton(
                text: _isLoading ? 'Creating...' : 'Create Task',
                onPressed: () {
                  if (_isLoading || _isGenerating) return;
                  AnalyticsService().logCreateTaskButtonTap();
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
