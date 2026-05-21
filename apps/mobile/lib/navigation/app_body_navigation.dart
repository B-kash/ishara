import 'package:flutter/material.dart';

import '../models/search_language.dart';
import 'app_routes.dart';

/// Pushes routes on the body [Navigator] inside [AppShell].
class AppBodyNavigation {
  AppBodyNavigation(this._navigatorKey);

  final GlobalKey<NavigatorState> _navigatorKey;

  NavigatorState? get _navigator => _navigatorKey.currentState;

  void pushSearch(String query) {
    _navigator?.pushNamed(
      AppRoutes.search,
      arguments: SearchRouteArguments(query: query),
    );
  }

  void pushBrowse(SearchLanguage language) {
    _navigator?.pushNamed(
      AppRoutes.browse,
      arguments: BrowseRouteArguments(language: language),
    );
  }

  void pushCategory({
    required String categoryId,
    required String categoryName,
    required SearchLanguage language,
  }) {
    _navigator?.pushNamed(
      AppRoutes.category,
      arguments: CategoryRouteArguments(
        categoryId: categoryId,
        categoryName: categoryName,
        language: language,
      ),
    );
  }

  void pushSignDetail(String signId) {
    _navigator?.pushNamed(
      AppRoutes.signDetail,
      arguments: SignDetailRouteArguments(signId: signId),
    );
  }

  void goHome() {
    final navigator = _navigator;
    if (navigator == null) {
      return;
    }

    final signApiClient = AppShellScope.of(navigator.context).signApiClient;
    navigator.pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
      arguments: HomeRouteArguments(signApiClient: signApiClient),
    );
  }

  void goBrowse(SearchLanguage language) {
    _navigator?.pushNamedAndRemoveUntil(
      AppRoutes.browse,
      (route) => false,
      arguments: BrowseRouteArguments(language: language),
    );
  }

  bool get canPop => _navigator?.canPop() ?? false;

  void pop() {
    _navigator?.pop();
  }
}

extension AppBodyNavigationContext on BuildContext {
  AppBodyNavigation get appBodyNavigation {
    final shellScope = AppShellScope.of(this);
    return AppBodyNavigation(shellScope.bodyNavigatorKey);
  }
}
