import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';
import 'providers/expense_database_provider.dart';
import 'providers/income_database_provider.dart';
import 'providers/settings_provider.dart';
import 'services/expense_database_service.dart';
import 'services/income_database_service.dart';
import 'services/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  final expenseDbService = ExpenseDatabaseService();
  await expenseDbService.init();

  final incomeDbService = IncomeDatabaseService();
  await incomeDbService.init();

  final settingsService = SettingsService();
  await settingsService.init();

  runApp(
    ProviderScope(
      overrides: [
        expenseDatabaseServiceProvider.overrideWithValue(expenseDbService),
        incomeDatabaseServiceProvider.overrideWithValue(incomeDbService),
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}