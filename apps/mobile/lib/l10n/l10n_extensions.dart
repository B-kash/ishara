import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../api/sign_api_client.dart';
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

String localizeErrorMessage(BuildContext context, Object error) {
  final l10n = AppLocalizations.of(context)!;

  if (error is SignApiException) {
    return error.localize(l10n);
  }

  return l10n.somethingWentWrong;
}
