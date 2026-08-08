import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/expense_database_service.dart';

/// Exposes the single [ExpenseDatabaseService] instance to the whole app.
///
/// The actual instance is created and initialized (Hive box opened) in
/// main.dart BEFORE runApp, then injected here via ProviderScope's
/// `overrides`. This provider's default body should never actually run —
/// it exists only to give the override something to target, and to throw
/// a clear error if we ever forget to override it.
final expenseDatabaseServiceProvider = Provider<ExpenseDatabaseService>((ref) {
  throw UnimplementedError(
    'expenseDatabaseServiceProvider must be overridden in main.dart '
        'with an already-initialized ExpenseDatabaseService instance.',
  );
});