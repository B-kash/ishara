import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/friendly_error_message.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/app_snackbar.dart';
import '../models/search_language.dart';
import '../models/sign_search_result.dart';
import '../state/async_view_state.dart';
import '../widgets/async_state_body.dart';
import '../widgets/sign_result_list_tile.dart';

class BrowseDictionaryScreen extends StatefulWidget {
  const BrowseDictionaryScreen({
    super.key,
    required this.signApiClient,
    required this.language,
  });

  final SignApiClient signApiClient;
  final SearchLanguage language;

  static const int pageSize = 2;

  @override
  State<BrowseDictionaryScreen> createState() => _BrowseDictionaryScreenState();
}

class _BrowseDictionaryScreenState extends State<BrowseDictionaryScreen> {
  final _scrollController = ScrollController();
  final List<SignSearchResult> _signs = [];

  AsyncViewState<void> _initialLoadState = AsyncViewState.loading();
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _nextCursor;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _isLoadingMore) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _loadNextPage();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _initialLoadState = AsyncViewState.loading();
      _signs.clear();
      _nextCursor = null;
      _hasMore = true;
    });

    try {
      final browsePage = await widget.signApiClient.listSigns(
        language: widget.language,
        limit: BrowseDictionaryScreen.pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _signs.addAll(browsePage.items);
        _nextCursor = browsePage.nextCursor;
        _hasMore = browsePage.hasMore;
        _initialLoadState = _signs.isEmpty
            ? AsyncViewState.empty()
            : AsyncViewState.success(null);
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final friendlyMessage = friendlyApiErrorMessage(
        context,
        error,
        FetchErrorContext.browseDictionary,
      );

      setState(() {
        _initialLoadState = AsyncViewState.error();
      });

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyMessage,
        onRetry: _loadFirstPage,
      );
    }
  }

  Future<void> _loadNextPage() async {
    if (!_hasMore || _isLoadingMore || _nextCursor == null) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final browsePage = await widget.signApiClient.listSigns(
        language: widget.language,
        cursor: _nextCursor,
        limit: BrowseDictionaryScreen.pageSize,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _signs.addAll(browsePage.items);
        _nextCursor = browsePage.nextCursor;
        _hasMore = browsePage.hasMore;
        _isLoadingMore = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
      });

      final friendlyMessage = friendlyApiErrorMessage(
        context,
        error,
        FetchErrorContext.browseDictionary,
      );

      showErrorSnackBar(context, message: friendlyMessage);
    }
  }

  Widget _buildLoadMoreFooter() {
    if (!_hasMore) {
      return const SizedBox(height: 16);
    }

    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return const SizedBox(height: 16);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.browseDictionaryTitle),
      ),
      body: AsyncStateBody<void>(
        state: _initialLoadState,
        onRetry: _loadFirstPage,
        emptyMessage: l10n.noSignsFound,
        successBuilder: (context, data) {
          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (var signIndex = 0; signIndex < _signs.length; signIndex++) ...[
                if (signIndex > 0) const Divider(height: 1),
                SignResultListTile(
                  signApiClient: widget.signApiClient,
                  sign: _signs[signIndex],
                ),
              ],
              _buildLoadMoreFooter(),
            ],
          );
        },
      ),
    );
  }
}
