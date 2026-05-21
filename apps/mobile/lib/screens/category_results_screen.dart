import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/friendly_error_message.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/app_snackbar.dart';
import '../models/search_language.dart';
import '../models/sign_search_result.dart';
import '../state/async_view_state.dart';
import '../navigation/app_body_navigation.dart';
import '../widgets/async_state_body.dart';

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
      final results = await widget.signApiClient.getSignsByCategory(
        categoryId: widget.categoryId,
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

      final friendlyMessage = friendlyApiErrorMessage(
        context,
        error,
        FetchErrorContext.categorySigns,
      );

      setState(() {
        _resultsState = AsyncViewState.error();
      });

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyMessage,
        onRetry: _loadResults,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            widget.categoryName,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        Expanded(
          child: AsyncStateBody<List<SignSearchResult>>(
            state: _resultsState,
            onRetry: _loadResults,
            emptyMessage: l10n.noSignsInCategory,
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
                      context.appBodyNavigation.pushSignDetail(sign.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
