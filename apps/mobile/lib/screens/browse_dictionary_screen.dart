import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../api/sign_api_client.dart';
import '../data/dictionary_alphabet.dart';
import '../l10n/friendly_error_message.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/app_snackbar.dart';
import '../models/search_language.dart';
import '../models/sign_search_result.dart';
import '../state/async_view_state.dart';
import '../widgets/async_state_body.dart';
import '../widgets/dictionary_letter_bar.dart';
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
  final _searchController = TextEditingController();
  final List<SignSearchResult> _signs = [];

  AsyncViewState<List<SignSearchResult>> _listState = AsyncViewState.loading();
  bool _isSearchMode = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _nextCursor;
  String? _browseLetter;
  SearchLanguage? _browseLetterLanguage;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadBrowseFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isSearchMode || !_hasMore || _isLoadingMore || !_scrollController.hasClients) {
      return;
    }

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= maxScroll - 200) {
      _loadBrowseNextPage();
    }
  }

  void _loadMoreIfListDoesNotScroll() {
    if (_isSearchMode) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_hasMore || _isLoadingMore || _nextCursor == null) {
        return;
      }

      if (!_scrollController.hasClients) {
        return;
      }

      final scrollPosition = _scrollController.position;
      final listFillsScreen =
          scrollPosition.maxScrollExtent > scrollPosition.viewportDimension * 0.1;

      if (!listFillsScreen) {
        _loadBrowseNextPage();
      }
    });
  }

  void _jumpToLetter(String letter, SearchLanguage letterLanguage) {
    _searchController.clear();
    setState(() {
      _isSearchMode = false;
      _browseLetter = letter;
      _browseLetterLanguage = letterLanguage;
    });
    _loadBrowseFirstPage();
  }

  void _clearLetterJump() {
    if (_browseLetter == null && _browseLetterLanguage == null) {
      return;
    }

    setState(() {
      _isSearchMode = false;
      _browseLetter = null;
      _browseLetterLanguage = null;
    });
    _loadBrowseFirstPage();
  }

  Future<void> _submitSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _isSearchMode = false;
      });
      _loadBrowseFirstPage();
      return;
    }

    setState(() {
      _isSearchMode = true;
      _listState = AsyncViewState.loading();
      _signs.clear();
      _hasMore = false;
      _nextCursor = null;
    });

    try {
      final results = await widget.signApiClient.searchSigns(query: query);

      if (!mounted) {
        return;
      }

      setState(() {
        _signs
          ..clear()
          ..addAll(results);
        _listState = _signs.isEmpty
            ? AsyncViewState.empty()
            : AsyncViewState.success(List<SignSearchResult>.from(_signs));
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _listState = AsyncViewState.error();
      });

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyApiErrorMessage(
          context,
          error,
          FetchErrorContext.browseDictionary,
        ),
        onRetry: _submitSearch,
      );
    }
  }

  Future<void> _loadBrowseFirstPage() async {
    setState(() {
      _listState = AsyncViewState.loading();
      _signs.clear();
      _nextCursor = null;
      _hasMore = true;
      _isSearchMode = false;
    });

    try {
      final browsePage = await widget.signApiClient.listSigns(
        language: widget.language,
        limit: BrowseDictionaryScreen.pageSize,
        letter: _browseLetter,
        letterLanguage: _browseLetterLanguage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _signs
          ..clear()
          ..addAll(browsePage.items);
        _nextCursor = browsePage.nextCursor;
        _hasMore = browsePage.hasMore;
        _listState = _signs.isEmpty
            ? AsyncViewState.empty()
            : AsyncViewState.success(List<SignSearchResult>.from(_signs));
      });

      _loadMoreIfListDoesNotScroll();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _listState = AsyncViewState.error();
      });

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyApiErrorMessage(
          context,
          error,
          FetchErrorContext.browseDictionary,
        ),
        onRetry: _loadBrowseFirstPage,
      );
    }
  }

  Future<void> _loadBrowseNextPage() async {
    if (_isSearchMode || !_hasMore || _isLoadingMore || _nextCursor == null) {
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
        letter: _browseLetter,
        letterLanguage: _browseLetterLanguage,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _signs.addAll(browsePage.items);
        _nextCursor = browsePage.nextCursor;
        _hasMore = browsePage.hasMore;
        _isLoadingMore = false;
        if (_listState.status == AsyncViewStatus.success) {
          _listState =
              AsyncViewState.success(List<SignSearchResult>.from(_signs));
        }
      });

      _loadMoreIfListDoesNotScroll();
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingMore = false;
      });

      showErrorSnackBar(
        context,
        message: friendlyApiErrorMessage(
          context,
          error,
          FetchErrorContext.browseDictionary,
        ),
      );
    }
  }

  Widget _buildLoadMoreFooter(BuildContext context) {
    if (_isSearchMode || !_hasMore) {
      return const SizedBox(height: 16);
    }

    if (_isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Center(
        child: FilledButton.tonal(
          onPressed: _nextCursor == null ? null : _loadBrowseNextPage,
          child: Text(l10n.loadMore),
        ),
      ),
    );
  }

  Widget _buildSignList(List<SignSearchResult> signs) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 8),
      children: [
        for (var signIndex = 0; signIndex < signs.length; signIndex++) ...[
          if (signIndex > 0) const Divider(height: 1),
          SignResultListTile(
            signApiClient: widget.signApiClient,
            sign: signs[signIndex],
          ),
        ],
        _buildLoadMoreFooter(context),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final alphabetPanelMaxHeight =
            (constraints.maxHeight * 0.42).clamp(140.0, 320.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                l10n.browseDictionaryTitle,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.browseDictionarySearchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _submitSearch();
                          },
                        ),
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) => _submitSearch(),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: alphabetPanelMaxHeight),
              child: SingleChildScrollView(
                child: DictionaryAlphabetPanel(
                  englishLetters: DictionaryAlphabet.englishLetters,
                  nepaliVowelLetters: DictionaryAlphabet.nepaliVowelLetters,
                  nepaliConsonantLetters:
                      DictionaryAlphabet.nepaliConsonantLetters,
                  selectedLetter: _browseLetter,
                  selectedLetterLanguage: _browseLetterLanguage,
                  enabled: !_isSearchMode,
                  onLetterSelected: _jumpToLetter,
                  onClearLetterJump: _clearLetterJump,
                ),
              ),
            ),
            Expanded(
              child: AsyncStateBody<List<SignSearchResult>>(
                state: _listState,
                onRetry: _isSearchMode ? _submitSearch : _loadBrowseFirstPage,
                emptyMessage: l10n.noSignsFound,
                successBuilder: (context, signs) => _buildSignList(signs),
              ),
            ),
          ],
        );
      },
    );
  }
}
