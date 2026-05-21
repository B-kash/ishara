import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../models/search_language.dart';
import '../models/sign_search_result.dart';
import '../state/async_view_state.dart';
import '../widgets/async_state_body.dart';
import 'sign_detail_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({
    super.key,
    required this.signApiClient,
    required this.query,
    required this.language,
  });

  final SignApiClient signApiClient;
  final String query;
  final SearchLanguage language;

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  AsyncViewState<List<SignSearchResult>> _resultsState =
      AsyncViewState.loading();

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _resultsState = AsyncViewState.loading();
    });

    try {
      final results = await widget.signApiClient.searchSigns(
        query: widget.query,
        language: widget.language,
      );

      setState(() {
        if (results.isEmpty) {
          _resultsState = AsyncViewState.empty();
        } else {
          _resultsState = AsyncViewState.success(results);
        }
      });
    } catch (error) {
      setState(() {
        _resultsState = AsyncViewState.error(error.toString());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Results for "${widget.query}"'),
      ),
      body: AsyncStateBody<List<SignSearchResult>>(
        state: _resultsState,
        onRetry: _loadResults,
        emptyMessage: 'No signs found. Try another word or category.',
        successBuilder: (context, results) {
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
                      builder: (context) => SignDetailScreen(
                        signApiClient: widget.signApiClient,
                        signId: sign.id,
                      ),
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
