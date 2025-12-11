import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier(ref);
});

class LocaleNotifier extends StateNotifier<Locale> {
  final Ref _ref;

  LocaleNotifier(this._ref) : super(_loadLocale()) {
    _initializeLocale();
  }

  static Locale _loadLocale() {
    return const Locale('en', 'US'); // Default locale
  }

  void _initializeLocale() {
    final savedLocale = HiveHelper.shared.getData<String?>(HiveBoxes.localeBox, HiveKeys.localeKey);
    if (savedLocale != null && savedLocale.isNotEmpty) {
      final parts = savedLocale.split('_');
      if (parts.length == 2 && parts[1].isNotEmpty) {
        final locale = Locale(parts[0], parts[1]);
        state = locale;
        _loadTranslations(locale.languageCode);
      } else {
        final locale = Locale(parts[0]);
        state = locale;
        _loadTranslations(locale.languageCode);
      }
    } else {
      _loadTranslations('en');
    }
  }

  void setLocale(Locale locale) {
    state = locale;
    final localeString = '${locale.languageCode}_${locale.countryCode ?? ''}';
    Hive.box<String?>(HiveBoxes.localeBox).put(HiveKeys.localeKey, localeString);
    _loadTranslations(locale.languageCode);
  }

  void _loadTranslations(String languageCode) {
    _ref.read(translationServiceProvider).loadTranslations(languageCode);
  }
}
