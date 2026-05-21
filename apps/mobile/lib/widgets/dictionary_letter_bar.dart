import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/l10n_extensions.dart';
import '../models/search_language.dart';

class DictionaryLetterBar extends StatelessWidget {
  const DictionaryLetterBar({
    super.key,
    required this.letters,
    required this.label,
    required this.letterLanguage,
    required this.selectedLetter,
    required this.onLetterSelected,
  });

  final List<String> letters;
  final String label;
  final SearchLanguage letterLanguage;
  final String? selectedLetter;
  final void Function(String letter, SearchLanguage letterLanguage) onLetterSelected;

  static double _minChipWidth(String letter, bool isNepali) {
    if (!isNepali) {
      return 36;
    }

    if (letter.length >= 3) {
      return 56;
    }

    if (letter.length >= 2) {
      return 48;
    }

    return 40;
  }

  Widget _buildLetterChip(String letter) {
    final isSelected =
        selectedLetter == letter && letterLanguage == this.letterLanguage;
    final isNepali = letterLanguage == SearchLanguage.nepali;
    final chipWidth = _minChipWidth(letter, isNepali);

    return SizedBox(
      width: chipWidth,
      child: ChoiceChip(
        label: SizedBox(
          width: double.infinity,
          child: Text(
            letter,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isNepali ? 17 : 15,
            ),
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onLetterSelected(letter, letterLanguage);
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final letter in letters) _buildLetterChip(letter),
          ],
        ),
      ],
    );
  }
}

class DictionaryAlphabetPanel extends StatelessWidget {
  const DictionaryAlphabetPanel({
    super.key,
    required this.englishLetters,
    required this.nepaliVowelLetters,
    required this.nepaliConsonantLetters,
    required this.selectedLetter,
    required this.selectedLetterLanguage,
    required this.onLetterSelected,
    this.enabled = true,
    this.initiallyExpanded = false,
    this.onClearLetterJump,
  });

  final List<String> englishLetters;
  final List<String> nepaliVowelLetters;
  final List<String> nepaliConsonantLetters;
  final String? selectedLetter;
  final SearchLanguage? selectedLetterLanguage;
  final void Function(String letter, SearchLanguage letterLanguage) onLetterSelected;
  final bool enabled;
  final bool initiallyExpanded;
  final VoidCallback? onClearLetterJump;

  String? _buildExpansionSubtitle(AppLocalizations l10n) {
    if (!enabled || selectedLetter == null || selectedLetterLanguage == null) {
      return null;
    }

    final languageLabel = selectedLetterLanguage == SearchLanguage.english
        ? l10n.englishLettersLabel
        : l10n.nepaliLettersLabel;

    return l10n.jumpToLetterSelected(languageLabel, selectedLetter!);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final expansionSubtitle = _buildExpansionSubtitle(l10n);

    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Material(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.35,
            ),
            borderRadius: BorderRadius.circular(12),
            child: ExpansionTile(
              initiallyExpanded: initiallyExpanded && enabled,
              title: Row(
                children: [
                  Expanded(
                    child: Text(l10n.jumpToLetterTitle),
                  ),
                  if (selectedLetter != null && onClearLetterJump != null)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: l10n.clearLetterJump,
                      onPressed: onClearLetterJump,
                    ),
                ],
              ),
              subtitle: Text(
                expansionSubtitle ?? l10n.jumpToLetterHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (selectedLetter != null && onClearLetterJump != null)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: onClearLetterJump,
                            icon: const Icon(Icons.clear),
                            label: Text(l10n.clearLetterJump),
                          ),
                        ),
                      DictionaryLetterBar(
                        letters: englishLetters,
                        label: l10n.englishLettersLabel,
                        letterLanguage: SearchLanguage.english,
                        selectedLetter:
                            selectedLetterLanguage == SearchLanguage.english
                                ? selectedLetter
                                : null,
                        onLetterSelected: onLetterSelected,
                      ),
                      DictionaryLetterBar(
                        letters: nepaliVowelLetters,
                        label: l10n.nepaliVowelsLabel,
                        letterLanguage: SearchLanguage.nepali,
                        selectedLetter:
                            selectedLetterLanguage == SearchLanguage.nepali
                                ? selectedLetter
                                : null,
                        onLetterSelected: onLetterSelected,
                      ),
                      DictionaryLetterBar(
                        letters: nepaliConsonantLetters,
                        label: l10n.nepaliConsonantsLabel,
                        letterLanguage: SearchLanguage.nepali,
                        selectedLetter:
                            selectedLetterLanguage == SearchLanguage.nepali
                                ? selectedLetter
                                : null,
                        onLetterSelected: onLetterSelected,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
