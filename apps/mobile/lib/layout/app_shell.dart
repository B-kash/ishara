import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../locale/locale_controller.dart';
import '../models/search_language.dart';
import '../navigation/app_routes.dart';
import '../theme/theme_controller.dart';
import 'app_footer.dart';
import 'app_header.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.signApiClient,
    required this.themeController,
    required this.localeController,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final GlobalKey<NavigatorState> _bodyNavigatorKey = GlobalKey<NavigatorState>();
  final _routeObserver = _BodyRouteObserver();
  bool _canPopBody = false;
  String? _currentRouteName = AppRoutes.home;
  bool _navigatorStateSyncScheduled = false;

  @override
  void initState() {
    super.initState();
    _routeObserver.onRouteChanged = _scheduleNavigatorStateSync;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncNavigatorState();
    });
  }

  @override
  void dispose() {
    _routeObserver.onRouteChanged = null;
    super.dispose();
  }

  void _scheduleNavigatorStateSync() {
    if (_navigatorStateSyncScheduled || !mounted) {
      return;
    }

    _navigatorStateSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigatorStateSyncScheduled = false;
      _syncNavigatorState();
    });
  }

  void _syncNavigatorState() {
    final navigator = _bodyNavigatorKey.currentState;
    if (!mounted) {
      return;
    }

    final nextCanPop = navigator?.canPop() ?? false;
    final nextRouteName = _routeObserver.currentRouteName ?? AppRoutes.home;

    if (nextCanPop == _canPopBody && nextRouteName == _currentRouteName) {
      return;
    }

    setState(() {
      _canPopBody = nextCanPop;
      _currentRouteName = nextRouteName;
    });
  }

  SearchLanguage get _browseLanguage {
    return searchLanguageFromLocale(widget.localeController.locale);
  }

  @override
  Widget build(BuildContext context) {
    return AppShellScope(
      signApiClient: widget.signApiClient,
      themeController: widget.themeController,
      localeController: widget.localeController,
      bodyNavigatorKey: _bodyNavigatorKey,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SafeArea(
              bottom: false,
              child: AppHeader(
                themeController: widget.themeController,
                localeController: widget.localeController,
                canPop: _canPopBody,
                onBack: () => _bodyNavigatorKey.currentState?.pop(),
              ),
            ),
            Expanded(
              child: Navigator(
                key: _bodyNavigatorKey,
                initialRoute: AppRoutes.home,
                observers: [_routeObserver],
                onGenerateRoute: generateAppBodyRoute,
                onGenerateInitialRoutes: (navigator, initialRoute) {
                  return [
                    generateAppBodyRoute(
                      RouteSettings(
                        name: AppRoutes.home,
                        arguments: HomeRouteArguments(
                          signApiClient: widget.signApiClient,
                        ),
                      ),
                    )!,
                  ];
                },
              ),
            ),
            AppFooter(
              currentRouteName: _currentRouteName,
              browseLanguage: _browseLanguage,
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyRouteObserver extends NavigatorObserver {
  VoidCallback? onRouteChanged;
  String? currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = route.settings.name;
    onRouteChanged?.call();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name ?? AppRoutes.home;
    onRouteChanged?.call();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    currentRouteName = previousRoute?.settings.name ?? AppRoutes.home;
    onRouteChanged?.call();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    currentRouteName = newRoute?.settings.name ?? AppRoutes.home;
    onRouteChanged?.call();
  }
}
