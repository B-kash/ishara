import 'package:flutter/material.dart';

import '../api/sign_api_client.dart';
import '../l10n/friendly_error_message.dart';
import '../l10n/l10n_extensions.dart';
import '../widgets/app_snackbar.dart';
import '../models/category.dart';
import '../models/search_language.dart';
import '../navigation/app_body_navigation.dart';
import '../navigation/app_routes.dart';
import '../state/async_view_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.signApiClient,
    super.key,
  });

  final SignApiClient signApiClient;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  AsyncViewState<List<Category>> _categoriesState = AsyncViewState.idle();

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _categoriesState = AsyncViewState.loading();
    });

    try {
      final categories = await widget.signApiClient.getCategories();
      if (!mounted) {
        return;
      }

      setState(() {
        if (categories.isEmpty) {
          _categoriesState = AsyncViewState.empty();
        } else {
          _categoriesState = AsyncViewState.success(categories);
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      final friendlyMessage = friendlyApiErrorMessage(
        context,
        error,
        FetchErrorContext.categories,
      );

      setState(() {
        _categoriesState = AsyncViewState.error();
      });

      showErrorSnackBarAfterBuild(
        context,
        message: friendlyMessage,
        onRetry: _loadCategories,
      );
    }
  }

  void _submitSearch() {
    final query = _searchController.text;
    if (query.trim().isEmpty) {
      return;
    }
    context.appBodyNavigation.pushSearch(query);
  }

  void _openCategory(Category category) {
    final categoryLanguage = searchLanguageFromLocale(
      AppShellScope.of(context).localeController.locale,
    );

    context.appBodyNavigation.pushCategory(
      categoryId: category.id,
      categoryName: category.name,
      language: categoryLanguage,
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    final l10n = context.l10n;

    switch (_categoriesState.status) {
      case AsyncViewStatus.idle:
        return const SizedBox.shrink();
      case AsyncViewStatus.loading:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: LinearProgressIndicator(),
        );
      case AsyncViewStatus.error:
        return TextButton.icon(
          onPressed: _loadCategories,
          icon: const Icon(Icons.refresh),
          label: Text(l10n.tryAgain),
        );
      case AsyncViewStatus.empty:
        return Text(
          l10n.noCategoriesYet,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        );
      case AsyncViewStatus.success:
        final categories = _categoriesState.data ?? [];
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
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
        const SizedBox(height: 24),
        Text(
          l10n.categoriesTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        _buildCategoriesSection(context),
      ],
    );
  }
}
