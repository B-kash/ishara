import 'package:flutter/material.dart';
import 'package:ishara/l10n/app_localizations.dart';

import '../api/sign_api_client.dart';
import 'l10n_extensions.dart';

enum FetchErrorContext {
  categories,
  search,
  categorySigns,
  browseDictionary,
  signDetail,
}

String friendlyApiErrorMessage(
  BuildContext context,
  Object error,
  FetchErrorContext fetchContext,
) {
  final l10n = context.l10n;

  if (error is SignApiException) {
    return _friendlySignApiError(l10n, error.kind, fetchContext);
  }

  return _defaultFriendlyMessage(l10n, fetchContext);
}

String _friendlySignApiError(
  AppLocalizations l10n,
  SignApiErrorKind errorKind,
  FetchErrorContext fetchContext,
) {
  switch (errorKind) {
    case SignApiErrorKind.signNotFound:
      return l10n.signNotFound;
    case SignApiErrorKind.categoryNotFound:
      return l10n.couldNotLoadCategories;
    case SignApiErrorKind.categoriesLoadFailed:
      return l10n.couldNotLoadCategories;
    case SignApiErrorKind.categorySignsLoadFailed:
      return l10n.couldNotReachApi;
    case SignApiErrorKind.browseDictionaryLoadFailed:
      return l10n.couldNotReachApi;
    case SignApiErrorKind.searchFailed:
      return l10n.couldNotReachApi;
    case SignApiErrorKind.signLoadFailed:
      return l10n.couldNotLoadSign;
  }
}

String _defaultFriendlyMessage(
  AppLocalizations l10n,
  FetchErrorContext fetchContext,
) {
  switch (fetchContext) {
    case FetchErrorContext.categories:
      return l10n.couldNotLoadCategories;
    case FetchErrorContext.search:
    case FetchErrorContext.categorySigns:
    case FetchErrorContext.browseDictionary:
      return l10n.couldNotReachApi;
    case FetchErrorContext.signDetail:
      return l10n.couldNotLoadSign;
  }
}
