import 'package:get/get.dart';
import 'package:lets_do_it/app/data/remote/remote_config_service.dart';
import 'package:lets_do_it/app/utils/utils.dart';
import 'package:firebase_core/firebase_core.dart';

class RemoteConfigController extends GetxController {
  final RemoteConfigService _remoteConfigService = RemoteConfigService();
  final RxInt maxFreeTasks = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadRemoteConfig();
  }

  Future<void> loadRemoteConfig() async {
    try {
      isLoading.value = true;

      await Firebase.initializeApp();

      await _remoteConfigService.initialize();
      final success = await _remoteConfigService.fetchAndActivate();

      if (success) {
        final limit = await _remoteConfigService.getTaskLimit();
        maxFreeTasks.value = limit;
        // Utils().successToast('Remote config updated', Get.context!);
      } else {
        Utils().failureToast('Failed to fetch remote config', Get.context!);
      }
    } catch (e) {
      Utils().failureToast('Remote Config Error: $e', Get.context!);
    } finally {
      isLoading.value = false;
    }
  }

  int get taskLimit => maxFreeTasks.value;
}
