import 'package:flutter/material.dart';

import '../theme/ishara_theme.dart';
import '../theme/theme_controller.dart';

class ThemeMenuButton extends StatelessWidget {
  const ThemeMenuButton({super.key, required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeController,
      builder: (context, child) {
        return PopupMenuButton<IsharaThemeId>(
          tooltip: 'Choose theme',
          icon: const Icon(Icons.palette_outlined),
          onSelected: themeController.setTheme,
          itemBuilder: (context) {
            return [
              for (final themeId in IsharaThemeId.values)
                PopupMenuItem<IsharaThemeId>(
                  value: themeId,
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 14,
                        color: themeId.seedColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(themeId.displayName)),
                      if (themeController.currentTheme == themeId)
                        Icon(
                          Icons.check,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    ],
                  ),
                ),
            ];
          },
        );
      },
    );
  }
}
