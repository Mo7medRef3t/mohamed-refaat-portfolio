import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_web_portfolio/app/controllers/language_controller.dart';
import 'package:flutter_web_portfolio/app/controllers/scene_director.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/constants/cinematic_curves.dart';
import 'package:flutter_web_portfolio/app/core/constants/durations.dart';
import 'package:flutter_web_portfolio/app/core/theme/app_typography.dart';
import 'package:flutter_web_portfolio/app/utils/responsive_utils.dart';
import 'package:flutter_web_portfolio/app/widgets/numbered_section_heading.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_config.dart';
import 'package:flutter_web_portfolio/app/widgets/animated_stats.dart';
import 'package:flutter_web_portfolio/app/widgets/scroll_fade_in.dart';
import 'package:flutter_web_portfolio/app/widgets/skill_orbit.dart';

/// About Section — "The Introduction"
/// Giant watermark, flashlight photo, floating tech pills, interactive skill tabs.
class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final isMobile = ResponsiveUtils.isMobile(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final data =
        languageController.cvData['personal_info'] as Map<String, dynamic>? ??
        <String, dynamic>{};

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 1100),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            left: -10,
            child: Obx(
              () => Text(
                languageController
                    .getText('nav.about', defaultValue: 'About')
                    .toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: ResponsiveUtils.getValueForScreenType<double>(
                    context: context,
                    mobile: 48.0,
                    tablet: screenWidth * 0.14,
                    desktop: screenWidth * 0.18,
                  ),
                  fontWeight: FontWeight.w800,
                  color: (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black)
                      .withValues(alpha: 0.03),
                  letterSpacing: -4,
                ),
              ),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              if (isMobile)
                _buildMobileLayout(data, languageController)
              else
                _buildDesktopLayout(data, languageController),
              // Animated stats row
              if (AppConfig.hasStats(languageController))
                ScrollFadeIn(
                  delay: AppDurations.staggerShort,
                  child: Obx(() {
                    final accent =
                        Get.find<SceneDirector>().currentAccent.value;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        if (AppConfig.yearsExperience(languageController) > 0)
                          AnimatedStatCard(
                            value: AppConfig.yearsExperience(
                              languageController,
                            ),
                            suffix: '+',
                            label: languageController.getText(
                              'about_section.years_exp',
                              defaultValue: 'Years Experience',
                            ),
                            accentColor: accent,
                          ),
                        if (AppConfig.projectsCompleted(languageController) > 0)
                          AnimatedStatCard(
                            value: AppConfig.projectsCompleted(
                              languageController,
                            ),
                            suffix: '+',
                            label: languageController.getText(
                              'about_section.projects',
                              defaultValue: 'Projects Completed',
                            ),
                            accentColor: accent,
                            delay: const Duration(milliseconds: 200),
                          ),
                        if (AppConfig.technologies(languageController) > 0)
                          AnimatedStatCard(
                            value: AppConfig.technologies(languageController),
                            suffix: '+',
                            label: languageController.getText(
                              'about_section.technologies',
                              defaultValue: 'Technologies',
                            ),
                            accentColor: accent,
                            delay: const Duration(milliseconds: 400),
                          ),
                      ],
                    );
                  }),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(
    Map<String, dynamic> data,
    LanguageController languageController,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        flex: 3,
        child: ScrollFadeIn(
          child: _BioContent(
            data: data,
            languageController: languageController,
          ),
        ),
      ),
      const SizedBox(width: 48),
      Expanded(
        flex: 2,
        child: ScrollFadeIn(
          delay: AppDurations.staggerMedium,
          child: _FlashlightPhoto(),
        ),
      ),
    ],
  );

  Widget _buildMobileLayout(
    Map<String, dynamic> data,
    LanguageController languageController,
  ) => Column(
    children: [
      ScrollFadeIn(child: _FlashlightPhoto()),
      const SizedBox(height: 32),
      ScrollFadeIn(
        delay: AppDurations.staggerMedium,
        child: _BioContent(data: data, languageController: languageController),
      ),
    ],
  );
}

// Bio content with interactive skill tabs
class _BioContent extends StatefulWidget {
  const _BioContent({required this.data, required this.languageController});

  final Map<String, dynamic> data;
  final LanguageController languageController;

  @override
  State<_BioContent> createState() => _BioContentState();
}

class _BioContentState extends State<_BioContent>
    with SingleTickerProviderStateMixin {
  int _selectedTabIndex = 0;
  int _hoveredTabIndex = -1;
  late AnimationController _contentAnimationController;
  late Animation<double> _contentFadeAnimation;
  late Animation<Offset> _contentSlideAnimation;

  @override
  void initState() {
    super.initState();
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _contentFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _contentSlideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimationController,
        curve: Curves.easeOut,
      ),
    );
    _contentAnimationController.forward();
  }

  @override
  void dispose() {
    _contentAnimationController.dispose();
    super.dispose();
  }

  void _onTabChanged(int newIndex) {
    if (newIndex == _selectedTabIndex) return;
    setState(() => _selectedTabIndex = newIndex);
    _contentAnimationController
      ..reset()
      ..forward();
  }

  List<Map<String, dynamic>> _getSkills() {
    final skills = widget.languageController.cvData['skills'] as List? ?? [];
    return skills.cast<Map<String, dynamic>>();
  }

  @override
  Widget build(BuildContext context) {
    final sceneDirector = Get.find<SceneDirector>();
    final isMobile = ResponsiveUtils.isMobile(context);
    final skills = _getSkills();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section label
        Obx(
          () => NumberedSectionHeading(
            number: '01',
            title: widget.languageController.getText(
              'about_section.title',
              defaultValue: 'About Me',
            ),
            accent: sceneDirector.currentAccent.value,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          (widget.data['bio'] as String?) ??
              widget.languageController.getText(
                'about_section.bio',
                defaultValue:
                    'I enjoy creating things that live on the internet, '
                    'whether that be websites, applications, or anything in between. '
                    'My goal is to always build products that provide pixel-perfect, '
                    'performant experiences.',
              ),
          style: AppTypography.body,
        ),
        const SizedBox(height: 16),
        Text(
          widget.languageController.getText(
            'about_section.bio2',
            defaultValue:
                'Here are a few technologies I\'ve been working with recently:',
          ),
          style: AppTypography.body,
        ),
        const SizedBox(height: 24),
        // Floating tech pills
        _FloatingTechPills(
          sceneDirector: sceneDirector,
          languageController: widget.languageController,
        ),
        const SizedBox(height: 32),
        // Skill orbit — desktop only
        if (!isMobile) ...[
          ScrollFadeIn(
            delay: AppDurations.staggerMedium,
            child: Obx(() {
              final accent = sceneDirector.currentAccent.value;
              if (skills.isEmpty) return const SizedBox.shrink();
              return ClipRect(
                child: SkillOrbit(skills: skills, accent: accent),
              );
            }),
          ),
          const SizedBox(height: 32),
        ],
        // Interactive Skill Tabs
        ScrollFadeIn(
          delay: AppDurations.staggerMedium,
          child: Obx(() {
            final accent = sceneDirector.currentAccent.value;
            if (skills.isEmpty) return const SizedBox.shrink();
            return _InteractiveSkillTabs(
              skills: skills,
              selectedIndex: _selectedTabIndex,
              hoveredIndex: _hoveredTabIndex,
              accent: accent,
              isMobile: isMobile,
              onTabChanged: _onTabChanged,
              onTabHovered: (index) => setState(() => _hoveredTabIndex = index),
              onTabUnhovered: () => setState(() => _hoveredTabIndex = -1),
              contentFade: _contentFadeAnimation,
              contentSlide: _contentSlideAnimation,
            );
          }),
        ),
      ],
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Interactive Skill Tabs — Professional tabbed interface
// ──────────────────────────────────────────────────────────────────────────────

class _InteractiveSkillTabs extends StatelessWidget {
  const _InteractiveSkillTabs({
    required this.skills,
    required this.selectedIndex,
    required this.hoveredIndex,
    required this.accent,
    required this.isMobile,
    required this.onTabChanged,
    required this.onTabHovered,
    required this.onTabUnhovered,
    required this.contentFade,
    required this.contentSlide,
  });

  final List<Map<String, dynamic>> skills;
  final int selectedIndex;
  final int hoveredIndex;
  final Color accent;
  final bool isMobile;
  final void Function(int) onTabChanged;
  final void Function(int) onTabHovered;
  final VoidCallback onTabUnhovered;
  final Animation<double> contentFade;
  final Animation<Offset> contentSlide;

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return _buildMobileLayout(context);
    }
    return _buildDesktopLayout(context);
  }

  Widget _buildDesktopLayout(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceOf(context).withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: 0.1), width: 1),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side: Tabs
        Container(
          width: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: accent.withValues(alpha: 0.1), width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12, left: 12),
                child: Text(
                  'Technical Expertise',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 11,
                    color: accent,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              ...List.generate(skills.length, (index) {
                final category = skills[index]['category'] as String;
                final isSelected = selectedIndex == index;
                final isHovered = hoveredIndex == index;
                return _SkillTab(
                  label: category,
                  isSelected: isSelected,
                  isHovered: isHovered,
                  accent: accent,
                  onTap: () => onTabChanged(index),
                  onHover: (hovered) {
                    if (hovered) {
                      onTabHovered(index);
                    } else {
                      onTabUnhovered();
                    }
                  },
                );
              }),
            ],
          ),
        ),
        // Right side: Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SlideFadeTransition(
              fadeAnimation: contentFade,
              slideAnimation: contentSlide,
              child: _buildTabContent(context, skills[selectedIndex]),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _buildMobileLayout(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: AppColors.surfaceOf(context).withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: accent.withValues(alpha: 0.1), width: 1),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Horizontal tabs
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          child: Row(
            children: List.generate(skills.length, (index) {
              final category = skills[index]['category'] as String;
              final isSelected = selectedIndex == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _SkillTab(
                  label: category,
                  isSelected: isSelected,
                  isHovered: false,
                  accent: accent,
                  onTap: () => onTabChanged(index),
                  onHover: (_) {},
                  compact: true,
                ),
              );
            }),
          ),
        ),
        Divider(color: accent.withValues(alpha: 0.1), height: 1),
        // Content
        Padding(
          padding: const EdgeInsets.all(20),
          child: SlideFadeTransition(
            fadeAnimation: contentFade,
            slideAnimation: contentSlide,
            child: _buildTabContent(context, skills[selectedIndex]),
          ),
        ),
      ],
    ),
  );

  Widget _buildTabContent(BuildContext context, Map<String, dynamic> skill) {
    final category = skill['category'] as String;
    final items = (skill['items'] as List?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              category,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textBrightOf(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              items
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        item as String,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.textPrimaryOf(context),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
        const SizedBox(height: 16),
        Text(
          '${items.length} technologies',
          style: GoogleFonts.jetBrainsMono(
            fontSize: 11,
            color: AppColors.textSecondaryOf(context).withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

// Individual skill tab
class _SkillTab extends StatefulWidget {
  const _SkillTab({
    required this.label,
    required this.isSelected,
    required this.isHovered,
    required this.accent,
    required this.onTap,
    required this.onHover,
    this.compact = false,
  });

  final String label;
  final bool isSelected;
  final bool isHovered;
  final Color accent;
  final VoidCallback onTap;
  final void Function(bool) onHover;
  final bool compact;

  @override
  State<_SkillTab> createState() => _SkillTabState();
}

class _SkillTabState extends State<_SkillTab> {
  @override
  Widget build(BuildContext context) => MouseRegion(
    cursor: SystemMouseCursors.click,
    onEnter: (_) => widget.onHover(true),
    onExit: (_) => widget.onHover(false),
    child: GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: Curves.easeOut,
        width: widget.compact ? null : double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: widget.compact ? 16 : 12,
          vertical: widget.compact ? 8 : 12,
        ),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color:
              widget.isSelected
                  ? widget.accent.withValues(alpha: 0.12)
                  : widget.isHovered
                  ? widget.accent.withValues(alpha: 0.06)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border:
              widget.isSelected
                  ? Border.all(
                    color: widget.accent.withValues(alpha: 0.3),
                    width: 1,
                  )
                  : Border.all(color: Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: widget.compact ? MainAxisSize.min : MainAxisSize.max,
          children: [
            if (widget.isSelected)
              Container(
                width: 4,
                height: 4,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  color: widget.accent,
                  shape: BoxShape.circle,
                ),
              ),
            Expanded(
              child: Text(
                widget.label,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: widget.compact ? 11 : 12,
                  color:
                      widget.isSelected
                          ? widget.accent
                          : widget.isHovered
                          ? AppColors.textBrightOf(context)
                          : AppColors.textSecondaryOf(context),
                  fontWeight:
                      widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (widget.isSelected)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: widget.accent,
              ),
          ],
        ),
      ),
    ),
  );
}

// Slide + Fade transition wrapper
class SlideFadeTransition extends StatelessWidget {
  const SlideFadeTransition({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.child,
  });

  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final Widget child;

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: fadeAnimation,
    child: SlideTransition(position: slideAnimation, child: child),
  );
}

// Floating tech pills — data-driven from cvData skills
class _FloatingTechPills extends StatelessWidget {
  const _FloatingTechPills({
    required this.sceneDirector,
    required this.languageController,
  });
  final SceneDirector sceneDirector;
  final LanguageController languageController;

  List<String> _getTechnologies() {
    final skills = languageController.cvData['skills'] as List? ?? [];
    return skills.map<String>((s) {
      final items = ((s as Map<String, dynamic>)['items'] as List?) ?? [];
      return items.take(2).join(' & ');
    }).toList();
  }

  @override
  Widget build(BuildContext context) => Obx(() {
    final accent = sceneDirector.currentAccent.value;
    final technologies = _getTechnologies();
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          technologies
              .map(
                (tech) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: accent.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    tech,
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: accent,
                    ),
                  ),
                ),
              )
              .toList(),
    );
  });
}

class _FlashlightPhoto extends StatefulWidget {
  @override
  State<_FlashlightPhoto> createState() => _FlashlightPhotoState();
}

class _FlashlightPhotoState extends State<_FlashlightPhoto> {
  final _mousePos = ValueNotifier<Offset>(const Offset(0.5, 0.5));
  final _hovered = ValueNotifier<bool>(false);

  /// Max tilt angle in radians (3 degrees).
  static const double _maxTilt = 3.0 * math.pi / 180.0;
  static const double _perspective = 0.001;
  static const double _shadowMultiplier = 8.0;

  @override
  void dispose() {
    _mousePos.dispose();
    _hovered.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return MouseRegion(
      onEnter: (_) => _hovered.value = true,
      onHover: (e) {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        _mousePos.value = Offset(
          e.localPosition.dx / box.size.width,
          e.localPosition.dy / box.size.height,
        );
      },
      onExit: (_) {
        _hovered.value = false;
        _mousePos.value = const Offset(0.5, 0.5);
      },
      child: ValueListenableBuilder<Offset>(
        valueListenable: _mousePos,
        builder:
            (context, mousePos, child) => ValueListenableBuilder<bool>(
              valueListenable: _hovered,
              builder: (context, hovered, _) {
                final dx = (mousePos.dx - 0.5) * 2.0;
                final dy = (mousePos.dy - 0.5) * 2.0;

                final tiltTransform =
                    Matrix4.identity()
                      ..setEntry(3, 2, _perspective)
                      ..rotateY(hovered ? dx * _maxTilt : 0)
                      ..rotateX(hovered ? -dy * _maxTilt : 0);

                final shadowOffsetX = hovered ? -dx * _shadowMultiplier : 0.0;
                final shadowOffsetY = hovered ? -dy * _shadowMultiplier : 0.0;

                return AnimatedContainer(
                  duration: AppDurations.medium,
                  curve: CinematicCurves.hoverLift,
                  transform: tiltTransform,
                  transformAlignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    boxShadow:
                        hovered
                            ? [
                              BoxShadow(
                                color: (isDark ? AppColors.heroAccent : AppColorsLight.heroAccent).withValues(
                                  alpha: 0.12,
                                ),
                                blurRadius: 30,
                                spreadRadius: 0,
                                offset: Offset(shadowOffsetX, shadowOffsetY),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: -4,
                                offset: Offset(
                                  shadowOffsetX * 0.5,
                                  shadowOffsetY * 0.5,
                                ),
                              ),
                            ]
                            : [],
                  ),
                  child: child,
                );
              },
            ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: ValueListenableBuilder<Offset>(
            valueListenable: _mousePos,
            builder:
                (context, mousePos, child) => ValueListenableBuilder<bool>(
                  valueListenable: _hovered,
                  builder:
                      (context, hovered, _) => ShaderMask(
                        blendMode: BlendMode.dstIn,
                        shaderCallback:
                            (bounds) => RadialGradient(
                              center: Alignment(
                                mousePos.dx * 2 - 1,
                                mousePos.dy * 2 - 1,
                              ),
                              radius: hovered ? 1.2 : 2.0,
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.8),
                                Colors.white.withValues(
                                  alpha: hovered ? 0.2 : 0.5,
                                ),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ).createShader(bounds),
                        child: child,
                      ),
                ),
            child: Semantics(
              image: true,
              label: 'Profile photo',
              child: Image.asset(
                'assets/images/me.jpg',
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder:
                    (_, __, ___) => AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        color: isDark ? AppColors.backgroundLight : AppColorsLight.backgroundLight,
                        child: Icon(
                          Icons.person,
                          size: 64,
                          color: (isDark ? AppColors.textSecondary : AppColorsLight.textSecondary).withValues(alpha: 0.3),
                        ),
                      ),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}