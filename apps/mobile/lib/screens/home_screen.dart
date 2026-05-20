import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import 'category_results_screen.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.signApiClient, super.key});

  final SignApiClient signApiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  SearchLanguage _language = SearchLanguage.english;
  late Future<List<Category>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = widget.signApiClient.getCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadCategories() {
    setState(() {
      _categoriesFuture = widget.signApiClient.getCategories();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Ishara',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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
            FutureBuilder<List<Category>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Could not load categories',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _reloadCategories,
                        child: const Text('Try again'),
                      ),
                    ],
                  );
                }

                final categories = snapshot.data ?? [];

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
              },
            ),
          ],
        ),
      ),
    );
  }
}
