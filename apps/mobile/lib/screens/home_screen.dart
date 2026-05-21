import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/l10n_extensions.dart';
import '../locale/locale_controller.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import '../state/async_view_state.dart';
import '../theme/theme_controller.dart';
import '../widgets/locale_menu_button.dart';
import '../widgets/theme_menu_button.dart';
import 'category_results_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.signApiClient,
    required this.themeController,
    required this.localeController,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;
  final LocaleController localeController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  SearchLanguage _language = SearchLanguage.english;
  AsyncViewState<List<Category>> _categoriesState = AsyncViewState.idle();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesState = AsyncViewState.loading();
    });

    try {
      final categories = await widget.signApiClient.getCategories();
      if (!mounted) {
        return;
      }

      setState(() {
        if (categories.isEmpty) {
          _categoriesState = AsyncViewState.empty();
        } else {
          _categoriesState = AsyncViewState.success(categories);
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _categoriesState = AsyncViewState.error(
          localizeErrorMessage(context, error),
        );
      });
    }
  }

  void _submitSearch() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchResultsScreen(
          signApiClient: widget.signApiClient,
          query: query,
          language: _language,
        ),
      ),
    );
  }

  void _openCategory(Category category) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => CategoryResultsScreen(
          signApiClient: widget.signApiClient,
          categoryId: category.id,
          categoryName: category.name,
          language: _language,
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final l10n = context.l10n;

    switch (_categoriesState.status) {
      case AsyncViewStatus.idle:
        return const SizedBox.shrink();
      case AsyncViewStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        );
      case AsyncViewStatus.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.couldNotLoadCategories,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _categoriesState.errorMessage ?? l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCategories,
              child: Text(l10n.tryAgain),
            ),
          ],
        );
      case AsyncViewStatus.empty:
        return Text(
          l10n.noCategoriesYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        );
      case AsyncViewStatus.success:
        final categories = _categoriesState.data ?? [];
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final category in categories)
              ActionChip(
                label: Text(category.name),
                onPressed: () => _openCategory(category),
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    l10n.appTitle,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                LocaleMenuButton(localeController: widget.localeController),
                const SizedBox(width: 4),
                ThemeMenuButton(themeController: widget.themeController),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.appSubtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _language == SearchLanguage.english
                    ? l10n.searchHintEnglish
                    : l10n.searchHintNepali,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _submitSearch,
                ),
                border: const OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (value) => _submitSearch(),
            ),
            const SizedBox(height: 16),
            SegmentedButton<SearchLanguage>(
              segments: [
                ButtonSegment(
                  value: SearchLanguage.english,
                  label: Text(l10n.searchLanguageEnglish),
                ),
                ButtonSegment(
                  value: SearchLanguage.nepali,
                  label: Text(l10n.searchLanguageNepali),
                ),
              ],
              selected: {_language},
              onSelectionChanged: (selected) {
                setState(() {
                  _language = selected.first;
                });
              },
            ),
            const SizedBox(height: 24),
            Text(
              l10n.categoriesTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildCategoriesSection(context),
          ],
        ),
      ),
    );
  }
}
