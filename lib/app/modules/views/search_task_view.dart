import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/task_card.dart';

class SearchTaskView extends StatefulWidget {
  const SearchTaskView({super.key});

  @override
  State<SearchTaskView> createState() => _SearchTaskViewState();
}

class _SearchTaskViewState extends State<SearchTaskView> {
  final TodoTaskController _controller = Get.find<TodoTaskController>();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _controller.searchTasks('');
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Please Confirm"),
          content: const Text("This action can’t be undone!"),
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
  void dispose() {
    _focusNode.unfocus();
    _searchController.clear();
    _controller.searchTasks('');
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) => _controller.searchTasks(value),
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
            onPressed: () {
              _searchController.clear();
              _controller.searchTasks('');
              FocusScope.of(context).requestFocus(_focusNode);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
        child: Obx(() {
          final List<TodoTask> filteredTasks = _controller.tasks.reversed
              .toList();

          if (filteredTasks.isEmpty) {
            return const Center(
              child: Text('No tasks found', style: TextStyle(fontSize: 16)),
            );
          }

          return ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
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
    );
  }
}
