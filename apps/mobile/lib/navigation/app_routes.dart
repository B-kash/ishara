import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../locale/locale_controller.dart';
import '../models/search_language.dart';
import '../theme/theme_controller.dart';
import '../screens/browse_dictionary_screen.dart';
import '../screens/category_results_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_results_screen.dart';
import '../screens/sign_detail_screen.dart';

/// Route names for the body [Navigator] inside [AppShell].
abstract final class AppRoutes {
  static const String home = '/';
  static const String browse = '/browse';
  static const String search = '/search';
  static const String category = '/category';
  static const String signDetail = '/sign-detail';
}

class SearchRouteArguments {
  const SearchRouteArguments({required this.query});

  final String query;
}

class BrowseRouteArguments {
  const BrowseRouteArguments({required this.language});

  final SearchLanguage language;
}

class CategoryRouteArguments {
  const CategoryRouteArguments({
    required this.categoryId,
    required this.categoryName,
    required this.language,
  });

  final String categoryId;
  final String categoryName;
  final SearchLanguage language;
}

class SignDetailRouteArguments {
  const SignDetailRouteArguments({required this.signId});

  final String signId;
}

Route<dynamic>? generateAppBodyRoute(RouteSettings settings) {
  final arguments = settings.arguments;

  switch (settings.name) {
    case AppRoutes.home:
      final homeArguments = arguments as HomeRouteArguments?;
      if (homeArguments == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => HomeScreen(
          signApiClient: homeArguments.signApiClient,
        ),
      );
    case AppRoutes.browse:
      final browseArguments = arguments as BrowseRouteArguments?;
      if (browseArguments == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => BrowseDictionaryScreen(
          signApiClient: _signApiClientFromContext(context),
          language: browseArguments.language,
        ),
      );
    case AppRoutes.search:
      final searchArguments = arguments as SearchRouteArguments?;
      if (searchArguments == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => SearchResultsScreen(
          signApiClient: _signApiClientFromContext(context),
          query: searchArguments.query,
        ),
      );
    case AppRoutes.category:
      final categoryArguments = arguments as CategoryRouteArguments?;
      if (categoryArguments == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => CategoryResultsScreen(
          signApiClient: _signApiClientFromContext(context),
          categoryId: categoryArguments.categoryId,
          categoryName: categoryArguments.categoryName,
          language: categoryArguments.language,
        ),
      );
    case AppRoutes.signDetail:
      final signDetailArguments = arguments as SignDetailRouteArguments?;
      if (signDetailArguments == null) {
        return null;
      }
      return MaterialPageRoute<void>(
        settings: settings,
        builder: (context) => SignDetailScreen(
          signApiClient: _signApiClientFromContext(context),
          signId: signDetailArguments.signId,
        ),
      );
    default:
      return null;
  }
}

SignApiClient _signApiClientFromContext(BuildContext context) {
  final shellScope = AppShellScope.of(context);
  return shellScope.signApiClient;
}

/// Inherited scope so body routes can read shared app services.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    required this.signApiClient,
    required this.themeController,
    required this.localeController,
    required this.bodyNavigatorKey,
    required super.child,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;
  final LocaleController localeController;
  final GlobalKey<NavigatorState> bodyNavigatorKey;

  static AppShellScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppShellScope>();
    assert(scope != null, 'AppShellScope not found in context');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppShellScope oldWidget) {
    return signApiClient != oldWidget.signApiClient ||
        themeController != oldWidget.themeController ||
        localeController != oldWidget.localeController ||
        bodyNavigatorKey != oldWidget.bodyNavigatorKey;
  }
}

class HomeRouteArguments {
  const HomeRouteArguments({required this.signApiClient});

  final SignApiClient signApiClient;
}
