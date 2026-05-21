import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';
import '../state/async_view_state.dart';

class AsyncStateBody<T> extends StatelessWidget {
  const AsyncStateBody({
    super.key,
    required this.state,
    required this.onRetry,
    required this.successBuilder,
    this.idleBuilder,
    this.loadingBuilder,
    this.emptyMessage,
    this.errorTitle,
  });

  final AsyncViewState<T> state;
  final VoidCallback onRetry;
  final Widget Function(BuildContext context, T data) successBuilder;
  final Widget Function(BuildContext context)? idleBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final String? emptyMessage;
  final String? errorTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    switch (state.status) {
      case AsyncViewStatus.idle:
        return idleBuilder?.call(context) ??
            const SizedBox.shrink();
      case AsyncViewStatus.loading:
        return loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());
      case AsyncViewStatus.error:
        return _MessagePanel(
          icon: Icons.cloud_off,
          title: errorTitle ?? l10n.couldNotReachApi,
          message: state.errorMessage ?? l10n.somethingWentWrong,
          actionLabel: l10n.tryAgain,
          onAction: onRetry,
        );
      case AsyncViewStatus.empty:
        return _MessagePanel(
          icon: Icons.search_off,
          title: l10n.noResults,
          message: emptyMessage ?? l10n.nothingHereYet,
        );
      case AsyncViewStatus.success:
        final data = state.data;
        if (data == null) {
          return _MessagePanel(
            icon: Icons.error_outline,
            title: errorTitle ?? l10n.couldNotReachApi,
            message: l10n.missingData,
            actionLabel: l10n.tryAgain,
            onAction: onRetry,
          );
        }

        if (data is List && data.isEmpty) {
          return _MessagePanel(
            icon: Icons.search_off,
            title: l10n.noResults,
            message: emptyMessage ?? l10n.nothingHereYet,
          );
        }

        return successBuilder(context, data);
    }
  }
}

class _MessagePanel extends StatelessWidget {
  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              FilledButton(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
