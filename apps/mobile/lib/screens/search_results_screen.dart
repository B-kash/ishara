import 'package:flutter/material.dart';

import '../data/mock_sign_repository.dart';
import '../models/sign.dart';
import 'sign_detail_screen.dart';

class SearchResultsScreen extends StatelessWidget {
  const SearchResultsScreen({
    super.key,
    required this.query,
    required this.language,
    this.category,
  });

  final String query;
  final SearchLanguage language;
  final String? category;

  @override
  Widget build(BuildContext context) {
    final results = searchSigns(
      query: query,
      language: language,
      category: category,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "$query"'),
      ),
      body: results.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No signs found. Try another word or category.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            )
          : ListView.separated(
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
            ),
    );
  }
}
