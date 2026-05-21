import 'package:flutter/material.dart';
import 'package:ishara/l10n/app_localizations.dart';

import '../theme/ishara_theme.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

extension IsharaThemeL10n on IsharaThemeId {
  String displayName(AppLocalizations l10n) {
    switch (this) {
      case IsharaThemeId.purple:
        return l10n.themeIshara;
      case IsharaThemeId.teal:
        return l10n.themeOcean;
      case IsharaThemeId.forest:
        return l10n.themeForest;
      case IsharaThemeId.slate:
        return l10n.themeSlate;
      case IsharaThemeId.night:
        return l10n.themeNight;
    }
  }
}

