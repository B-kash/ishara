import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../locale/locale_controller.dart';
import '../theme/theme_controller.dart';
import '../widgets/locale_menu_button.dart';
import '../widgets/theme_menu_button.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    required this.themeController,
    required this.localeController,
    required this.canPop,
    required this.onBack,
    super.key,
  });

  final ThemeController themeController;
  final LocaleController localeController;
  final bool canPop;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Material(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canPop)
              IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: onBack,
              )
            else
              const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appSubtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            LocaleMenuButton(localeController: localeController),
            const SizedBox(width: 4),
            ThemeMenuButton(themeController: themeController),
          ],
        ),
      ),
    );
  }
}
