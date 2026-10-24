import 'package:flutter/material.dart';
import 'package:manager/core/errors/app_exception.dart';
import 'package:manager/core/logging/app_logger.dart';
import 'package:manager/l10n/l10n.dart';

/// Runs a user-triggered async [action] and reports a failure with a
/// localized snackbar instead of letting it escape as an unhandled error.
///
/// Returns true when the action completed.
Future<bool> runUiAction(
  BuildContext context,
  Future<void> Function() action,
) async {
  // Capture before the first await: the widget may be gone afterwards.
  final messenger = ScaffoldMessenger.maybeOf(context);
  final l10n = context.l10n;
  final errorColor = Theme.of(context).colorScheme.error;

  try {
    await action();
    return true;
  } on Object catch (error, stackTrace) {
    AppLogger.warn('UiAction', 'action failed', error, stackTrace);
    final reason = error is AppException ? error.message : error.toString();
    messenger
      ?..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.actionFailed(reason)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: errorColor,
        ),
      );
    return false;
  }
}
