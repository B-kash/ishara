import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import '../state/async_view_state.dart';
import '../theme/theme_controller.dart';
import '../widgets/theme_menu_button.dart';
import 'category_results_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.signApiClient,
    required this.themeController,
    super.key,
  });

  final SignApiClient signApiClient;
  final ThemeController themeController;

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
      setState(() {
        if (categories.isEmpty) {
          _categoriesState = AsyncViewState.empty();
        } else {
          _categoriesState = AsyncViewState.success(categories);
        }
      });
    } catch (error) {
      setState(() {
        _categoriesState = AsyncViewState.error(error.toString());
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
              'Could not load categories',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _categoriesState.errorMessage ?? 'Something went wrong.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loadCategories,
              child: const Text('Try again'),
            ),
          ],
        );
      case AsyncViewStatus.empty:
        return Text(
          'No categories yet.',
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
                    'Ishara',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                ThemeMenuButton(themeController: widget.themeController),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nepali Sign Language dictionary',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: _language == SearchLanguage.english
                    ? 'Search in English'
                    : 'नेपालीमा खोज्नुहोस्',
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
              segments: const [
                ButtonSegment(
                  value: SearchLanguage.english,
                  label: Text('English'),
                ),
                ButtonSegment(
                  value: SearchLanguage.nepali,
                  label: Text('Nepali'),
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
              'Categories',
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
