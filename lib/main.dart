import 'dart:async';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/json_decode_strategy.dart';
import 'package:get/get.dart';

import 'package:flutter_web_portfolio/app/bindings/app_bindings.dart';
import 'package:flutter_web_portfolio/app/controllers/loading_controller.dart';
import 'package:flutter_web_portfolio/app/controllers/language_controller.dart';
import 'package:flutter_web_portfolio/app/controllers/theme_controller.dart';
import 'package:flutter_web_portfolio/app/core/constants/app_colors.dart';
import 'package:flutter_web_portfolio/app/core/theme/app_theme.dart';
import 'package:flutter_web_portfolio/app/routes/app_pages.dart';
import 'package:flutter_web_portfolio/app/widgets/loading_animation.dart';
import 'package:flutter_web_portfolio/app/widgets/mouse_interaction_wrapper.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();
      SemanticsBinding.instance.ensureSemantics();

      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        dev.log('Flutter error', name: 'Main', error: details.exception);
      };

      _printConsoleAsciiArt();

      AppBindings().dependencies();

      final loadingController = Get.put(LoadingController(), permanent: true);
      Get.put(ThemeController(), permanent: true);

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      );

      initializeApp(loadingController).then((_) {
        runApp(const MyApp());
      });
    },
    (error, stack) {
      dev.log('Uncaught error', name: 'Main', error: error, stackTrace: stack);
    },
  );
}

void _printConsoleAsciiArt() {
  if (kIsWeb) {
    // ignore: avoid_print
    print('''

 ╔═══════════════════════════════╗
 ║   Flutter Developer Portfolio ║
 ║   Built with Clean Architecture
 ║   ─────────────────────────── ║
 ║   Psst... try Ctrl+K         ║
 ═══════════════════════════════╝

''');
  }
}

Future<void> initializeApp(LoadingController loadingController) async {
  try {
    final languageController = Get.find<LanguageController>();
    await languageController.loadSavedLanguage();
  } catch (e) {
    dev.log('App initialization failed', name: 'Main', error: e);
  } finally {
    loadingController.setLoading(false);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loadingController = Get.find<LoadingController>();
    final themeController = Get.find<ThemeController>();

    return Obx(() {
      var currentLocale = const Locale('en');
      var appTitle = 'Mohamed Refaat - Mobile Software Engineer';
      var textDirection = TextDirection.ltr;

      if (Get.isRegistered<LanguageController>()) {
        final languageController = Get.find<LanguageController>();
        currentLocale = languageController.currentLocale;

        // Get name from CV data if available
        final personalInfo =
            languageController.cvData['personal_info'] as Map<String, dynamic>?;
        final name = personalInfo?['name'] as String?;
        final title = personalInfo?['title'] as String?;
        if (name != null && title != null) {
          appTitle = '$name - $title';
        }

        if (languageController.currentLanguage == 'ar') {
          textDirection = TextDirection.rtl;
        }
      }

      return GetMaterialApp(
        title: appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode:
            themeController.isDarkMode.value ? ThemeMode.dark : ThemeMode.light,
        transitionDuration: const Duration(milliseconds: 400),
        locale: currentLocale,
        fallbackLocale: const Locale('en'),
        localizationsDelegates: [
          FlutterI18nDelegate(
            translationLoader: FileTranslationLoader(
              fallbackFile: 'en',
              basePath: 'assets/i18n',
              forcedLocale: currentLocale,
              decodeStrategies: [JsonDecodeStrategy()],
            ),
          ),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('tr'),
          Locale('de'),
          Locale('fr'),
          Locale('es'),
          Locale('ar'),
          Locale('hi'),
        ],
        getPages: AppPages.routes,
        unknownRoute: AppPages.unknownRoute,
        initialRoute: AppPages.initial,
        defaultTransition: Transition.fadeIn,
        builder: (context, child) {
          final wrappedApp = FlutterI18n.rootAppBuilder()(context, child);

          Widget content = Container(
            color:
                loadingController.isLoading
                    ? AppColors.background
                    : Colors.transparent,
            child:
                loadingController.isLoading
                    ? const LoadingAnimation()
                    : wrappedApp,
          );

          content = Directionality(
            textDirection: textDirection,
            child: content,
          );

          if (!kIsWeb) return content;
          return MouseInteractionWrapper(child: content);
        },
      );
    });
  }
}
