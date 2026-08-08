import 'package:flutter/material.dart';

/// Reusable Yes/No confirmation dialog — used for delete confirmations
/// (Expense Detail screen) and any other destructive action.
/// Returns `true` if confirmed, `false`/`null` if cancelled or dismissed.
class ConfirmDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmLabel = 'Delete',
    String cancelLabel = 'Cancel',
    bool isDestructive = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: isDestructive
                  ? Theme.of(context).colorScheme.error
                  : null,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }
}