import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lets_do_it/app/data/remote/remote_config_service.dart';
import 'package:lets_do_it/app/modules/views/add_task_view.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class PayForTasksView extends StatelessWidget {
  const PayForTasksView({super.key});

  Future<int> _getLimit() async {
    final remoteConfigService = RemoteConfigService();
    return await remoteConfigService.getTaskLimit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upgrade Your Plan")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<int>(
          future: _getLimit(),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final taskLimit = snapshot.data ?? 2;

            return Skeletonizer(
              enabled: isLoading,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    hasError
                        ? 'Failed to load task limit 😕'
                        : "You've reached your free tasks limit 🎯",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasError
                        ? 'Something went wrong fetching your task limit.'
                        : "You can manage up to $taskLimit tasks for free.\n\n"
                              "Upgrade your plan to unlock unlimited tasks and better productivity tools.",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  ExpandedButton(
                    text: 'Return',
                    onPressed: () {
                      // Try disposing the previous screen as well (for example, AddTaskView)
                      if (Get.isRegistered<AddTaskView>()) {
                        Get.delete<AddTaskView>();
                      }

                      // Go back two screens in navigation
                      Get.close(2);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
