import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ishara_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({IsharaThemeId initialTheme = IsharaThemeId.purple})
      : _currentTheme = initialTheme;

  static const String _storageKey = 'ishara_theme_id';

  IsharaThemeId _currentTheme;

  IsharaThemeId get currentTheme => _currentTheme;

  ThemeData get themeData => IsharaThemes.build(_currentTheme);

  Future<void> loadSavedTheme() async {
    final preferences = await SharedPreferences.getInstance();
    final savedThemeId = IsharaThemeId.fromStorageKey(
      preferences.getString(_storageKey),
    );

    if (savedThemeId == null || savedThemeId == _currentTheme) {
      return;
    }

    _currentTheme = savedThemeId;
    notifyListeners();
  }

  Future<void> setTheme(IsharaThemeId themeId) async {
    if (_currentTheme == themeId) {
      return;
    }

    _currentTheme = themeId;
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, themeId.storageKey);
  }
}
