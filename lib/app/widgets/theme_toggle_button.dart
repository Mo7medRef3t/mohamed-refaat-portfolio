import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_portfolio/app/controllers/theme_controller.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/constants/durations.dart';
import 'package:flutter_web_portfolio/app/widgets/cinematic_focusable.dart';

class ThemeToggleButton extends StatefulWidget {
  const ThemeToggleButton({super.key});

  @override
  State<ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends State<ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.medium,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleTheme() {
    final themeController = Get.find<ThemeController>()
    ..toggleTheme();

    if (themeController.isDarkMode.value) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Obx(() {
      final isDarkMode = Get.find<ThemeController>().isDarkMode.value;
      final iconColor = isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;

      return Semantics(
        button: true,
        label: isDarkMode ? 'Switch to light mode' : 'Switch to dark mode',
        child: CinematicFocusable(
          onTap: _toggleTheme,
          onHoverChanged: (_) {},
          borderRadius: BorderRadius.circular(8),
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) => Transform.rotate(
              angle: _rotationAnimation.value * 3.14159,
              child: child,
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.backgroundLight.withValues(alpha: 0.5)
                    : AppColorsLight.backgroundLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark
                      ? AppColors.textSecondary.withValues(alpha: 0.2)
                      : AppColorsLight.textSecondary.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: AnimatedSwitcher(
                duration: AppDurations.fast,
                child: Icon(
                  isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  key: ValueKey(isDarkMode),
                  size: 20,
                  color: iconColor,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}