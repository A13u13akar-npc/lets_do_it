import 'package:get/get.dart';
import 'package:lets_do_it/app/data/remote/remote_config_service.dart';
import '../utils/utils.dart';

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
    isLoading.value = true;
    final success = await _remoteConfigService.fetchAndActivate();
    if (success) {
      final limit = await _remoteConfigService.getTaskLimit();
      maxFreeTasks.value = limit;
      Utils().successToast('Remote config updated', Get.context!);
    } else {
      Utils().failureToast('Failed to fetch remote config', Get.context!);
    }
    isLoading.value = false;
  }

  int get taskLimit => maxFreeTasks.value;
}
