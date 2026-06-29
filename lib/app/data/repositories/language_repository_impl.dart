import 'dart:developer' as dev;

import 'package:flutter_web_portfolio/app/domain/providers/i_assets_provider.dart';
import 'package:flutter_web_portfolio/app/domain/providers/i_local_storage_provider.dart';
import 'package:flutter_web_portfolio/app/domain/repositories/i_language_repository.dart';

/// JSON-backed language repo — reads translations from assets, persists preference.
final class LanguageRepositoryImpl implements ILanguageRepository {
  LanguageRepositoryImpl({
    required IAssetsProvider assetsProvider,
    required ILocalStorageProvider localStorageProvider,
  }) : _assetsProvider = assetsProvider,
       _localStorageProvider = localStorageProvider;
  final IAssetsProvider _assetsProvider;
  final ILocalStorageProvider _localStorageProvider;

  static const String _languageKey = 'selected_language';

  static const Map<String, String> _supportedLanguages = {
    'en': '\u{1F1EC}\u{1F1E7}',
    // 'ar': '\u{1F1F8}\u{1F1E6}',
  };

  @override
  Map<String, String> getSupportedLanguages() => _supportedLanguages;

  @override
  Future<String> getSelectedLanguage() async {
    try {
      final savedLanguage = _localStorageProvider.getString(_languageKey);
      return savedLanguage ?? 'en';
    } catch (e) {
      dev.log(
        'Failed to load language preference',
        name: 'LanguageRepository',
        error: e,
      );
      return 'en';
    }
  }

  @override
  Future<void> saveSelectedLanguage(String languageCode) async {
    try {
      await _localStorageProvider.setString(_languageKey, languageCode);
    } catch (e) {
      dev.log(
        'Failed to save language preference',
        name: 'LanguageRepository',
        error: e,
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getTranslations(String languageCode) async =>
      _assetsProvider.loadTranslations(languageCode);
}
