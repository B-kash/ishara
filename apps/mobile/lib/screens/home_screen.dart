import 'package:flutter/material.dart';

import '../data/mock_sign_repository.dart';
import '../models/sign.dart';
import 'search_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  SearchLanguage _language = SearchLanguage.english;
  String? _selectedCategory;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => SearchResultsScreen(
          query: query,
          language: _language,
          category: _selectedCategory,
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedCategory == null,
                  onSelected: (isSelected) {
                    if (isSelected) {
                      setState(() => _selectedCategory = null);
                    }
                  },
                ),
                for (final category in mockCategories)
                  FilterChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category : null;
                      });
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
