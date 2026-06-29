import 'package:flutter/material.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';

extension ThemeColors on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  Color get backgroundColor =>
      isDarkMode ? AppColors.background : AppColorsLight.background;
  Color get backgroundLightColor =>
      isDarkMode ? AppColors.backgroundLight : AppColorsLight.backgroundLight;
  Color get textBrightColor =>
      isDarkMode ? AppColors.textBright : AppColorsLight.textBright;
  Color get textPrimaryColor =>
      isDarkMode ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondaryColor =>
      isDarkMode ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get accentColor =>
      isDarkMode ? AppColors.accent : AppColorsLight.accent;
  Color get surfaceColor =>
      isDarkMode ? AppColors.surface : AppColorsLight.surface;
}
