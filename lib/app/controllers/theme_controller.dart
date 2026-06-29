import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller for managing light/dark theme switching.
class ThemeController extends GetxController {
  final RxBool isDarkMode = true.obs;

  ThemeMode get themeMode =>
      isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
  }

  void setDarkMode(bool value) {
    isDarkMode.value = value;
  }
}
