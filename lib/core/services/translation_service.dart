import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final translationServiceProvider = Provider<TranslationService>((ref) {
  return TranslationService();
});

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  Map<String, dynamic> _translations = {};
  String _currentLanguage = 'en';

  Future<void> loadTranslations(String languageCode) async {
    try {
      final String response = await rootBundle.loadString('assets/translations/$languageCode.json');
      _translations = json.decode(response);
      _currentLanguage = languageCode;
    } catch (e) {
      // Fallback to English if translation file not found
      if (languageCode != 'en') {
        await loadTranslations('en');
      }
    }
  }

  String translate(String key) {
    final keys = key.split('.');
    dynamic value = _translations;

    for (final k in keys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return key; // Return key if translation not found
      }
    }

    return value is String ? value : key;
  }

  String get currentLanguage => _currentLanguage;
}
