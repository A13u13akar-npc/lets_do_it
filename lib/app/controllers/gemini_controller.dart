import 'dart:developer';
import 'package:get/get.dart';
import 'package:lets_do_it/app/data/gemini_services.dart';

class GeminiController extends GetxController {
  final GeminiService _geminiService = GeminiService();

  final RxBool isGenerating = false.obs;
  final RxString generatedTitle = ''.obs;
  final RxString generatedDescription = ''.obs;

  Future<void> generateTask() async {
    try {
      isGenerating.value = true;
      final result = await _geminiService.generateTask();

      log("Response: $result",name: "gemini_testing");
      generatedTitle.value = result['title'] ?? '';
      generatedDescription.value = result['description'] ?? '';
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate task: $e');
    } finally {
      isGenerating.value = false;
    }
  }

  void clearGeneratedTask() {
    generatedTitle.value = '';
    generatedDescription.value = '';
  }
}
