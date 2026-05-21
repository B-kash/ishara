import 'package:flutter/material.dart';

enum IsharaThemeId {
  purple('purple', 'Ishara', Color(0xFF6750A4)),
  teal('teal', 'Ocean', Color(0xFF00796B)),
  forest('forest', 'Forest', Color(0xFF388E3C)),
  slate('slate', 'Slate', Color(0xFF546E7A)),
  night('night', 'Night', Color(0xFF7C4DFF));

  const IsharaThemeId(this.storageKey, this.displayName, this.seedColor);

  final String storageKey;
  final String displayName;
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
