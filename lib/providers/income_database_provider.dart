import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/income_database_service.dart';

final incomeDatabaseServiceProvider = Provider<IncomeDatabaseService>((ref) {
  throw UnimplementedError(
    'incomeDatabaseServiceProvider must be overridden in main.dart '
        'with an already-initialized IncomeDatabaseService instance.',
  );
});