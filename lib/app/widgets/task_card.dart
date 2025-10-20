import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/data/model/task_model.dart';

class TaskCard extends StatelessWidget {
  final TodoTask task;
  final VoidCallback? onDismissed;
  final Future<bool?> Function()? onConfirmDismiss;

  const TaskCard({
    super.key,
    required this.task,
    this.onDismissed,
    this.onConfirmDismiss,
  });

  String _formatDate(DateTime date) {
    return DateFormat('MMM d, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final TaskController taskController = Get.find<TaskController>();

    return Dismissible(
      key: Key(task.key.toString()),
      background: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          color: Colors.green,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(Icons.done_all_rounded, color: Colors.white, size: 36),
        ),
      ),
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) async => onConfirmDismiss != null ? await onConfirmDismiss!() : true,
      onDismissed: (_) => onDismissed?.call(),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: () async {
            final result = await Get.toNamed('/taskDetails', arguments: task);
            if (result == true) {
              await taskController.fetchTasks();
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: ListTile(
            title: Hero(
              tag: 'title_${task.key}',
              child: Material(
                color: Colors.transparent,
                child: Text(
                  task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (task.description != null && task.description!.trim().isNotEmpty)
                  Hero(
                    tag: 'desc_${task.key}',
                    child: Material(
                      color: Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(task.description!, style: const TextStyle(fontSize: 15)),
                      ),
                    ),
                  ),
                Hero(
                  tag: 'time_${task.key}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      'Created: ${_formatDate(task.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
