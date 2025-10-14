import 'package:flutter/material.dart';
import 'package:lets_do_it/app/data/model/todoModel.dart';

class TodoListTile extends StatelessWidget {
  final TodoTask task;
  final VoidCallback onCompleted;
  final VoidCallback onDelete; // New callback for delete functionality

  const TodoListTile({
    super.key,
    required this.task,
    required this.onCompleted,
    required this.onDelete, // Include onDelete in constructor
  });

  @override
  Widget build(BuildContext context) {
    // Fetch theme data
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? theme.cardColor : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.white10 : Colors.black26,
            blurRadius: 4.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            '${task.startTime} - ${task.endTime}',
            style: TextStyle(
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            color: Colors.grey,
            iconSize: 28,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text("Confirm"),
                    content: const Text(
                        "Are you sure you want to delete this task?"),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text("CANCEL"),
                      ),
                      TextButton(
                        onPressed: () {
                          onDelete(); // Call the onDelete callback if confirmed
                          Navigator.of(context).pop();
                        },
                        child: const Text("DELETE"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
