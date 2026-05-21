import 'package:flutter/material.dart';

import '../locale/locale_controller.dart';
import '../l10n/l10n_extensions.dart';

class LocaleMenuButton extends StatelessWidget {
  const LocaleMenuButton({super.key, required this.localeController});

  final LocaleController localeController;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: localeController,
      builder: (context, child) {
        return PopupMenuButton<Locale>(
          tooltip: l10n.chooseAppLanguage,
          icon: const Icon(Icons.language),
          onSelected: localeController.setLocale,
          itemBuilder: (context) {
            return [
              _buildLocaleItem(
                context: context,
                locale: const Locale('en'),
                label: l10n.searchLanguageEnglish,
                isSelected: localeController.locale.languageCode == 'en',
              ),
              _buildLocaleItem(
                context: context,
                locale: const Locale('ne'),
                label: l10n.searchLanguageNepali,
                isSelected: localeController.locale.languageCode == 'ne',
              ),
            ];
          },
        );
      },
    );
  }

  PopupMenuItem<Locale> _buildLocaleItem({
    required BuildContext context,
    required Locale locale,
    required String label,
    required bool isSelected,
  }) {
    return PopupMenuItem<Locale>(
      value: locale,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (isSelected)
            Icon(
              Icons.check,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
