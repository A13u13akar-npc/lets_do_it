import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_do_it/app/controllers/task_controller.dart';
import 'package:lets_do_it/app/data/services/ad_service.dart';
import 'package:lets_do_it/app/data/services/remote_config_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WatchAdForFreeTaskView extends StatelessWidget {
  const WatchAdForFreeTaskView({super.key});


  Future<void> _handleAdReward(
      TaskController taskController,
      String title,
      String? description,
      BuildContext context,
      ) async {
    try {
      await AdService.showRewardedInterstitialAd(
        onReward: (RewardItem reward) async {
          await taskController.addTask(
            title: title,
            description: description ?? '',
            clearFormCallback: taskController.clearForm,
            ignoreLimit: true,
          );
          await taskController.fetchTasks();
          Get.close(2);
          Utils().successToast('Rewarded a task!', Get.context!);
        },
      );
    } catch (_) {
      Utils().failureToast(
        'Failed to show ad. Please try again later.',
        context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskController = Get.find<TaskController>();
    // AdService.init();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final title = args['title'] ?? '';
    final description = args['description'] as String?;

    return Scaffold(
      appBar: AppBar(title: const Text("Plan Limit Reached 😕")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<int>(
          future: RemoteConfigService.getTaskLimit(),
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;
            final hasError = snapshot.hasError;
            final taskLimit = snapshot.data ?? 2;

            return Column(
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
                Skeletonizer(
                  enabled: isLoading,
                  child: Text(
                    hasError
                        ? 'Something went wrong fetching your task limit.'
                        : "You can manage up to $taskLimit tasks for free.\n\n"
                        "Don't worry! You can watch an ad for a free task!",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 40),
                Obx(() {
                  final isCreating = taskController.isCreatingTask.value;
                  return Skeletonizer(
                    enabled: isCreating,
                    child: ExpandedButton(
                      text: isCreating ? 'Showing Ad...' : 'Watch Ad',
                      onPressed: isCreating
                          ? () {}
                          : () => _handleAdReward(taskController, title, description, context),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}
