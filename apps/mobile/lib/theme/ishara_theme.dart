import 'package:flutter/material.dart';

enum IsharaThemeId {
  purple('purple', Color(0xFF6750A4)),
  teal('teal', Color(0xFF00796B)),
  forest('forest', Color(0xFF388E3C)),
  slate('slate', Color(0xFF546E7A)),
  night('night', Color(0xFF7C4DFF));

  const IsharaThemeId(this.storageKey, this.seedColor);

  final String storageKey;
  final Color seedColor;

  static IsharaThemeId? fromStorageKey(String? storageKey) {
    if (storageKey == null) {
      return null;
    }

    for (final themeId in IsharaThemeId.values) {
      if (themeId.storageKey == storageKey) {
        return themeId;
      }
    }

    return null;
  }
}

class IsharaThemes {
  static ThemeData build(IsharaThemeId themeId) {
    final brightness =
        themeId == IsharaThemeId.night ? Brightness.dark : Brightness.light;

    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeId.seedColor,
        brightness: brightness,
      ),
      useMaterial3: true,
    );
  }
}
