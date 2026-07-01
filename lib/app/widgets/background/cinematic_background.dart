import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_web_portfolio/app/controllers/scene_director.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/constants/scene_configs.dart';

/// Cinematic background: animated gradient mesh + vignette + film grain.
/// Colors shift based on SceneDirector's blendedConfig.
/// Theme-aware: uses light colors in light mode, dark colors in dark mode.
class CinematicBackground extends StatefulWidget {
  const CinematicBackground({super.key});

  @override
  State<CinematicBackground> createState() => _CinematicBackgroundState();
}

class _CinematicBackgroundState extends State<CinematicBackground>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animController;
  Offset _mouseOffset = Offset.zero;

  late SceneConfig _config;
  late Worker _configWorker;

  ui.Image? _grainTexture;
  int _lastGrainSeed = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    final sceneDirector = Get.find<SceneDirector>();
    _config = sceneDirector.blendedConfig.value;
    _configWorker = ever(sceneDirector.blendedConfig, (cfg) {
      _config = cfg;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _configWorker.dispose();
    _animController.dispose();
    _grainTexture?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      _animController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _animController.repeat();
    }
  }

  void _onMouseMove(PointerEvent event) {
    final size = context.size;
    if (size == null) return;
    _mouseOffset = Offset(
      (event.localPosition.dx / size.width - 0.5) * 2,
      (event.localPosition.dy / size.height - 0.5) * 2,
    );
  }

  void _updateGrainTexture(Size size) {
    // في الـ Light Mode، مش محتاجين film grain
    if (Theme.of(context).brightness != Brightness.dark) return;

    final seed = (_animController.value * 1000).toInt();
    if (seed == _lastGrainSeed && _grainTexture != null) return;
    _lastGrainSeed = seed;

    _grainTexture?.dispose();

    const grainSize = 256.0;
    final recorder = ui.PictureRecorder();
    final grainCanvas = Canvas(recorder);
    final random = math.Random(seed);
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.015);

    for (var i = 0; i < 40; i++) {
      final x = random.nextDouble() * grainSize;
      final y = random.nextDouble() * grainSize;
      final r = 0.5 + random.nextDouble() * 0.5;
      grainCanvas.drawCircle(Offset(x, y), r, paint);
    }

    final picture = recorder.endRecording();
    _grainTexture = picture.toImageSync(256, 256);
    picture.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExcludeSemantics(
      child: Listener(
        onPointerHover: _onMouseMove,
        onPointerMove: _onMouseMove,
        behavior: HitTestBehavior.translucent,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animController,
            builder: (context, _) {
              _updateGrainTexture(MediaQuery.sizeOf(context));
              return CustomPaint(
                painter: _MeshGradientPainter(
                  animValue: _animController.value,
                  gradient1: isDark ? _config.gradient1 : _getLightGradient1(),
                  gradient2: isDark ? _config.gradient2 : _getLightGradient2(),
                  gradient3: isDark ? _config.gradient3 : _getLightGradient3(),
                  mouseOffset: _mouseOffset,
                  vignetteIntensity: isDark ? _config.vignetteIntensity : 0.05,
                  grainImage: isDark ? _grainTexture : null,
                  isDark: isDark,
                ),
                size: Size.infinite,
              );
            },
          ),
        ),
      ),
    );
  }

  // Light mode gradients - soft, pastel colors
  Color _getLightGradient1() {
    final sceneIdx = Get.find<SceneDirector>().currentSceneIndex.value;
    switch (sceneIdx) {
      case 0:
        return AppColorsLight.heroGradient1;
      case 1:
        return AppColorsLight.aboutGradient1;
      case 2:
        return AppColorsLight.expGradient1;
      case 3:
        return AppColorsLight.projGradient1;
      case 4:
        return AppColorsLight.contactGradient1;
      default:
        return AppColorsLight.heroGradient1;
    }
  }

  Color _getLightGradient2() {
    final sceneIdx = Get.find<SceneDirector>().currentSceneIndex.value;
    switch (sceneIdx) {
      case 0:
        return AppColorsLight.heroGradient2;
      case 1:
        return AppColorsLight.aboutGradient2;
      case 2:
        return AppColorsLight.expGradient2;
      case 3:
        return AppColorsLight.projGradient2;
      case 4:
        return AppColorsLight.contactGradient2;
      default:
        return AppColorsLight.heroGradient2;
    }
  }

  Color _getLightGradient3() {
    final sceneIdx = Get.find<SceneDirector>().currentSceneIndex.value;
    switch (sceneIdx) {
      case 0:
        return AppColorsLight.heroGradient3;
      case 1:
        return AppColorsLight.aboutGradient3;
      case 2:
        return AppColorsLight.expGradient3;
      case 3:
        return AppColorsLight.projGradient3;
      case 4:
        return AppColorsLight.contactGradient3;
      default:
        return AppColorsLight.heroGradient3;
    }
  }
}

class _MeshGradientPainter extends CustomPainter {
  _MeshGradientPainter({
    required this.animValue,
    required this.gradient1,
    required this.gradient2,
    required this.gradient3,
    required this.mouseOffset,
    required this.vignetteIntensity,
    required this.grainImage,
    required this.isDark,
  });

  final double animValue;
  final Color gradient1;
  final Color gradient2;
  final Color gradient3;
  final Offset mouseOffset;
  final double vignetteIntensity;
  final ui.Image? grainImage;
  final bool isDark;

  static final _basePaint = Paint();
  static final _blobPaint = Paint()..blendMode = BlendMode.screen;
  static final _vignettePaint = Paint();
  static final _grainPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Base color - theme-aware
    _basePaint.color =
        isDark ? AppColors.background : AppColorsLight.background;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _basePaint);

    final t = animValue * math.pi * 2;

    // في الـ Light Mode، نقلل الـ alpha عشان الـ gradient يكون ناعم
    final alphaMultiplier = isDark ? 1.0 : 0.4;

    final blobs = [
      _BlobConfig(
        center: Offset(
          size.width *
              (0.25 + 0.15 * math.sin(t * 0.7) + mouseOffset.dx * 0.02),
          size.height *
              (0.3 + 0.15 * math.cos(t * 0.5) + mouseOffset.dy * 0.02),
        ),
        radius: size.width * 0.45,
        color: gradient1.withValues(alpha: 0.25 * alphaMultiplier),
      ),
      _BlobConfig(
        center: Offset(
          size.width *
              (0.75 + 0.12 * math.cos(t * 0.6) + mouseOffset.dx * 0.015),
          size.height *
              (0.25 + 0.18 * math.sin(t * 0.8) + mouseOffset.dy * 0.015),
        ),
        radius: size.width * 0.4,
        color: gradient2.withValues(alpha: 0.2 * alphaMultiplier),
      ),
      _BlobConfig(
        center: Offset(
          size.width *
              (0.5 + 0.2 * math.sin(t * 0.4 + 1.5) + mouseOffset.dx * 0.025),
          size.height *
              (0.7 + 0.12 * math.cos(t * 0.9 + 0.8) + mouseOffset.dy * 0.025),
        ),
        radius: size.width * 0.5,
        color: gradient3.withValues(alpha: 0.15 * alphaMultiplier),
      ),
      _BlobConfig(
        center: Offset(
          size.width * (0.6 + 0.1 * math.cos(t * 0.3 + 2.0)),
          size.height * (0.5 + 0.15 * math.sin(t * 0.5 + 1.2)),
        ),
        radius: size.width * 0.35,
        color: gradient1.withValues(alpha: 0.12 * alphaMultiplier),
      ),
    ];

    // في الـ Light Mode، نستخدم BlendMode.multiply بدل screen
    if (!isDark) {
      _blobPaint.blendMode = BlendMode.multiply;
    }

    final fullRect = Rect.fromLTWH(0, 0, size.width, size.height);
    for (final blob in blobs) {
      _blobPaint.shader = ui.Gradient.radial(
        blob.center,
        blob.radius,
        [blob.color, blob.color.withValues(alpha: 0)],
        [0.0, 1.0],
      );
      canvas.drawRect(fullRect, _blobPaint);
    }

    // Vignette overlay - أخف في الـ Light Mode
    _vignettePaint.shader = ui.Gradient.radial(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.7,
      [
        Colors.transparent,
        (isDark ? Colors.black : Colors.white).withValues(
          alpha: vignetteIntensity * 0.3,
        ),
        (isDark ? Colors.black : Colors.white).withValues(
          alpha: vignetteIntensity * 0.5,
        ),
      ],
      [0.3, 0.7, 1.0],
    );
    canvas.drawRect(fullRect, _vignettePaint);

    // Film grain - بس في الـ Dark Mode
    if (isDark) {
      _drawGrain(canvas, size);
    }
  }

  void _drawGrain(Canvas canvas, Size size) {
    if (grainImage == null) return;
    const tileSize = 256.0;
    for (double x = 0; x < size.width; x += tileSize) {
      for (double y = 0; y < size.height; y += tileSize) {
        final dstWidth = math.min(tileSize, size.width - x);
        final dstHeight = math.min(tileSize, size.height - y);
        final dst = Rect.fromLTWH(x, y, dstWidth, dstHeight);
        final srcCropped = Rect.fromLTWH(0, 0, dstWidth, dstHeight);
        canvas.drawImageRect(grainImage!, srcCropped, dst, _grainPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_MeshGradientPainter old) =>
      animValue != old.animValue ||
      gradient1 != old.gradient1 ||
      gradient2 != old.gradient2 ||
      gradient3 != old.gradient3 ||
      vignetteIntensity != old.vignetteIntensity ||
      isDark != old.isDark;
}

class _BlobConfig {
  const _BlobConfig({
    required this.center,
    required this.radius,
    required this.color,
  });
  final Offset center;
  final double radius;
  final Color color;
}
