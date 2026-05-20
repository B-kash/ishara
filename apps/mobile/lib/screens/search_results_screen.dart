import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/search_language.dart';
import '../models/sign.dart';
import 'sign_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.signApiClient,
    required this.query,
    required this.language,
    this.category,
  });

  final SignApiClient signApiClient;
  final String query;
  final SearchLanguage language;
  final String? category;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  late Future<List<Sign>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _loadResults();
  }

  Future<List<Sign>> _loadResults() async {
    final apiResults = await widget.signApiClient.searchSigns(
      query: widget.query,
      language: widget.language,
    );

    final selectedCategory = widget.category;
    if (selectedCategory == null) {
      return apiResults;
    }

    return apiResults
        .where((sign) => sign.category == selectedCategory)
        .toList();
  }

  void _retrySearch() {
    setState(() {
      _resultsFuture = _loadResults();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
      ),
      body: FutureBuilder<List<Sign>>(
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
                      onPressed: _retrySearch,
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
                  'No signs found. Try another word or category.',
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
