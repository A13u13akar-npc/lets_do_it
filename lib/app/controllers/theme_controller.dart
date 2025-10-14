import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class ThemeController extends GetxController {
  static const String _boxName = 'settings';
  static const String _themeKey = 'isDarkMode';

  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final box = await Hive.openBox(_boxName);
    isDarkMode.value = box.get(_themeKey, defaultValue: false);
    _updateThemeMode();
  }

  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    final box = await Hive.openBox(_boxName);
    await box.put(_themeKey, isDarkMode.value);
    _updateThemeMode();
  }

  void _updateThemeMode() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
}
