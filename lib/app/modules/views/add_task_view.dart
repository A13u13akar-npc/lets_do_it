import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:lets_do_it/app/controllers/analytics_controller.dart';
import 'package:lets_do_it/app/controllers/gemini_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/data/task_service.dart';
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
  final GeminiController _geminiController = Get.find<GeminiController>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final AnalyticsController _analyticsController = Get.find<AnalyticsController>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _openBox();
    ever(_geminiController.generatedTitle, (_) {
      _titleController.text = _geminiController.generatedTitle.value;
    });
    ever(_geminiController.generatedDescription, (_) {
      _descriptionController.text =
          _geminiController.generatedDescription.value;
    });
  }

  Future<void> _openBox() async {
    await Hive.openBox<TodoTask>('tasks');
  }

  Future<void> _addTask() async {
    FocusScope.of(context).unfocus();
    if (_isLoading || _geminiController.isGenerating.value) return;

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


  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _geminiController.clearGeneratedTask();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
          child: Obx(() {
            final isGenerating = _geminiController.isGenerating.value;

            return Column(
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
                              onPressed: isGenerating
                                  ? null
                                  : _geminiController.generateTask,
                              icon: const Icon(Icons.auto_awesome),
                              tooltip: 'Generate with AI',
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Column(
                          children: [
                            Skeletonizer(
                              enabled: isGenerating,
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
                              enabled: isGenerating,
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
                    if (_isLoading || isGenerating) return;
                    // AnalyticsService().logCreateTaskButtonTap();
                    _analyticsController.logCreateTaskButtonTap();
                    if (_formKey.currentState?.validate() == true) {
                      _addTask();
                    }
                  },
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
