import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/database/database_service.dart';

class SettingsController extends GetxController {
  final RxBool useDynamicColor = true.obs;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    final box = DatabaseService.settings;
    useDynamicColor.value = box.get('useDynamicColor', defaultValue: true);

    final modeIndex = box.get(
      'themeMode',
      defaultValue: ThemeMode.system.index,
    );
    themeMode.value = ThemeMode.values[modeIndex];
  }

  Future<void> toggleDynamicColor(bool value) async {
    useDynamicColor.value = value;
    await DatabaseService.settings.put('useDynamicColor', value);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    Get.changeThemeMode(mode);
    await DatabaseService.settings.put('themeMode', mode.index);
    debugPrint("Theme changed");
  }

  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode.value == ThemeMode.dark;
  }
}
