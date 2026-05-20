import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/search_language.dart';
import '../models/sign_search_result.dart';
import 'sign_detail_screen.dart';

class CategoryResultsScreen extends StatefulWidget {
  const CategoryResultsScreen({
    super.key,
    required this.signApiClient,
    required this.categoryId,
    required this.categoryName,
    required this.language,
  });

  final SignApiClient signApiClient;
  final String categoryId;
  final String categoryName;
  final SearchLanguage language;

  @override
  State<CategoryResultsScreen> createState() => _CategoryResultsScreenState();
}

class _CategoryResultsScreenState extends State<CategoryResultsScreen> {
  late Future<List<SignSearchResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _loadResults();
  }

  Future<List<SignSearchResult>> _loadResults() {
    return widget.signApiClient.getSignsByCategory(
      categoryId: widget.categoryId,
      language: widget.language,
    );
  }

  void _retryLoad() {
    setState(() {
      _resultsFuture = _loadResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<SignSearchResult>>(
        future: _resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_off, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Could not reach the API',
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _retryLoad,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No signs in this category yet.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: results.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final sign = results[index];
              return ListTile(
                title: Text(sign.englishWord),
                subtitle: Text('${sign.nepaliWord} · ${sign.category}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => SignDetailScreen(sign: sign),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
