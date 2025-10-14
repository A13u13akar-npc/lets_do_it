import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lets_do_it/app/data/model/todoModel.dart';
import 'package:lets_do_it/app/modules/views/homeScreen.dart';
import 'package:lets_do_it/app/utils/utils.dart';

class TodoService {
  Future<void> deleteTask(TodoTask task) async {
    await task.delete();
  }

  Future<void> addTask({
    required String taskDescription,
    required String startTime,
    required String endTime,
    required bool isCompleted,
    required BuildContext context,
    required VoidCallback clearFormCallback,
  }) async {
    if (taskDescription.trim().isEmpty) {
      throw Exception('Task name cannot be empty');
    }

    final box = Hive.box<TodoTask>('tasks');

    // Check if a task with the same name already exists
    final existingTask = box.values.firstWhere(
          (task) => task.title == taskDescription,
      orElse: () => TodoTask('', '', '', false), // Return a default TodoTask instance
    );

    if (existingTask.title.isNotEmpty) {
      // Show confirmation dialog
      bool confirmUpdate = await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirm Update'),
            content: const Text('Do you want to update this task?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false); // Return false on cancel
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true); // Return true on confirm
                },
                child: const Text('Update'),
              ),
            ],
          );
        },
      );

      // If user confirms update, proceed
      if (confirmUpdate == true) {
        // Update existing task with new data
        existingTask.startTime = startTime;
        existingTask.endTime = endTime;
        existingTask.isCompleted = isCompleted;
        await existingTask.save(); // Save changes to Hive
        Utils().greentoastmsg('Task updated successfully', context);
        _showTaskAddedDialog('Task Updated Successfully',context, clearFormCallback);
      }
    } else {
      // Add the task to the Hive box if it doesn't already exist
      final task = TodoTask(
        taskDescription,
        startTime,
        endTime,
        isCompleted,
      );

      await box.add(task);
      Utils().greentoastmsg('Task added successfully', context);
      _showTaskAddedDialog('Task Added Successfully',context, clearFormCallback);
    }
  }

  void _showTaskAddedDialog(String msg ,BuildContext context, VoidCallback clearFormCallback) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        // Access the current theme
        final ThemeData theme = Theme.of(context);

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(32.0),
            decoration: BoxDecoration(
              color: theme.dialogBackgroundColor, // Use theme's dialog background color
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Text(
                    msg,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ), // Use theme's headline6 for title
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    'Would you like to create another task or views existing tasks?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 18,
                    ), // Use theme's bodyText2 for content
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Flexible(
                      fit: FlexFit.tight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button background color
                          foregroundColor: Colors.white, // Text color inside the button
                          elevation: 0, // Remove shadow for no border outline effect
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          clearFormCallback();
                        },
                        child: const Text('Create Another Task'),
                      ),
                    ),
                    const SizedBox(width: 10), // Space between the buttons
                    Flexible(
                      fit: FlexFit.tight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button background color
                          foregroundColor: Colors.white, // Text color inside the button
                          elevation: 0, // Remove shadow for no border outline effect
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Utils().pushReplaceSlideTransition(context, HomeScreen());
                        },
                        child: const Text('View All Tasks'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
