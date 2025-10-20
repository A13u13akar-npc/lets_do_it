import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox('settings');
    isDarkMode.value = box.get('isDarkMode', defaultValue: false);
    _updateThemeMode();
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final box = await Hive.openBox('isDarkMode');
    await box.put('isDarkMode', isDarkMode.value);
    _updateThemeMode();
  }

  void _updateThemeMode() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
