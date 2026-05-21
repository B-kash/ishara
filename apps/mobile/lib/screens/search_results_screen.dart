import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/l10n_extensions.dart';
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

      if (!mounted) {
        return;
      }

      setState(() {
        if (results.isEmpty) {
          _resultsState = AsyncViewState.empty();
        } else {
          _resultsState = AsyncViewState.success(results);
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _resultsState = AsyncViewState.error(
          localizeErrorMessage(context, error),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resultsFor(widget.query)),
      ),
      body: AsyncStateBody<List<SignSearchResult>>(
        state: _resultsState,
        onRetry: _loadResults,
        emptyMessage: l10n.noSignsFound,
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
