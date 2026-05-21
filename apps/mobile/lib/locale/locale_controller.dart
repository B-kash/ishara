import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({Locale initialLocale = const Locale('en')})
      : _locale = initialLocale;

  static const String _storageKey = 'ishara_locale';

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ne'),
  ];

  Locale _locale;

  Locale get locale => _locale;

  Future<void> loadSavedLocale() async {
    final preferences = await SharedPreferences.getInstance();
    final savedLanguageCode = preferences.getString(_storageKey);

    if (savedLanguageCode == null) {
      return;
    }

    final savedLocale = Locale(savedLanguageCode);
    if (!_isSupported(savedLocale)) {
      return;
    }

    if (savedLocale == _locale) {
      return;
    }

    _locale = savedLocale;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    if (!_isSupported(locale) || _locale == locale) {
      return;
    }

    _locale = locale;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, locale.languageCode);
  }

  bool _isSupported(Locale locale) {
    return supportedLocales.any(
      (supportedLocale) => supportedLocale.languageCode == locale.languageCode,
    );
  }
}
