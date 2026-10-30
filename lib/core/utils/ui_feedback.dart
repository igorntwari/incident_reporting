import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';

import '../theme/app_colors.dart';

extension UiFeedback on BuildContext {
  void showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.danger : AppColors.textPrimary,
      ));
  }

  Future<bool> confirm({
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor:
                  destructive ? AppColors.danger : AppColors.primary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

extension ActionErrorListener on WidgetRef {
  /// Shows a snackbar whenever an action controller transitions to error.
  /// One line in a screen's `build` replaces hand-written error handling.
  void listenForErrors(
    ProviderListenable<AsyncValue<void>> provider,
    BuildContext context,
  ) {
    listen(provider, (_, next) {
      if (next is AsyncError) {
        context.showSnack(next.error.toString(), isError: true);
      }
    });
  }
}
