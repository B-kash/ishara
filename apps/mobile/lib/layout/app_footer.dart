import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../models/search_language.dart';
import '../navigation/app_body_navigation.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({
    required this.currentRouteName,
    required this.browseLanguage,
    super.key,
  });

  final String? currentRouteName;
  final SearchLanguage browseLanguage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bodyNavigation = context.appBodyNavigation;

    final browseSelected = currentRouteName == '/browse';

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: SafeArea(
        top: false,
        child: NavigationBar(
          selectedIndex: browseSelected ? 1 : 0,
          onDestinationSelected: (destinationIndex) {
            if (destinationIndex == 0) {
              bodyNavigation.goHome();
              return;
            }
            bodyNavigation.goBrowse(browseLanguage);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: const Icon(Icons.home),
              label: l10n.appTitle,
            ),
            NavigationDestination(
              icon: const Icon(Icons.menu_book_outlined),
              selectedIcon: const Icon(Icons.menu_book),
              label: l10n.browseDictionaryTitle,
            ),
          ],
        ),
      ),
    );
  }
}
