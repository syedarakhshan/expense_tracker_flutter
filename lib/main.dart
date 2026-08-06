import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

void main() {
  runApp(
    // ProviderScope makes Riverpod providers available to the whole tree.
    // We'll start adding real providers from Step 5 onward.
    const ProviderScope(child: ExpenseTrackerApp()),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system, // Step 13 will make this user-controlled
      routerConfig: appRouter,
    );
  }
}