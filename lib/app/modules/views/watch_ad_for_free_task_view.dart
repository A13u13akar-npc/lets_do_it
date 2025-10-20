import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lets_do_it/app/data/services/ad_service.dart';
import 'package:lets_do_it/app/data/services/remote_config_service.dart';
import 'package:lets_do_it/app/data/services/task_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:lets_do_it/app/widgets/expanded_button.dart';
import 'package:skeletonizer/skeletonizer.dart';

class WatchAdForFreeTaskView extends StatefulWidget {
  const WatchAdForFreeTaskView({super.key});

  @override
  State<WatchAdForFreeTaskView> createState() => _WatchAdForFreeTaskViewState();
}

class _WatchAdForFreeTaskViewState extends State<WatchAdForFreeTaskView> {
  final TaskService _todoService = TaskService();
  bool _isAdShowing = false;

  @override
  void initState() {
    super.initState();
    AdService.init();
  }

  Future<void> _handleAdReward(
    String title,
    String? description,
    BuildContext context,
  ) async {
    setState(() => _isAdShowing = true);
    try {
      AdService.showRewardedInterstitialAd(
        onReward: (RewardItem reward) async {
          await _todoService.addTask(
            title: title,
            description: description,
            context: context,
            clearFormCallback: () {},
            ignoreLimit: true,
          );
          Get.close(2);
          Get.toNamed('/viewTask');
        },
        context: context /**/,
      );
    } catch (_) {
      Utils().failureToast(
        'Failed to show ad. Please try again later.',
        context,
      );
      setState(() => _isAdShowing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String title = args?['title'] ?? '';
    final String? description = args?['description'];

    return Scaffold(
      appBar: AppBar(title: const Text("Plan Limit Reached 😕")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder<int>(
          future: RemoteConfigService.getTaskLimit(),
          builder: (context, snapshot) {
            final isLoading =
                snapshot.connectionState == ConnectionState.waiting;
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
                Skeletonizer(
                  enabled: _isAdShowing,
                  child: ExpandedButton(
                    text: _isAdShowing ? 'Showing Ad...' : 'Watch Ad',
                    onPressed: _isAdShowing
                        ? () {}
                        : () => _handleAdReward(title, description, context),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
