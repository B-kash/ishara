import 'package:flutter/material.dart';

import '../l10n/l10n_extensions.dart';

void showErrorSnackBar(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      action: onRetry == null
          ? null
          : SnackBarAction(
              label: context.l10n.tryAgain,
              onPressed: onRetry,
            ),
    ),
  );
}

void showErrorSnackBarAfterBuild(
  BuildContext context, {
  required String message,
  VoidCallback? onRetry,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) {
      return;
    }

    showErrorSnackBar(context, message: message, onRetry: onRetry);
  });
}
