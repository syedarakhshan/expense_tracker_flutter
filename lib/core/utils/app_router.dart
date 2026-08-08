import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../screens/income/income_screen.dart';
import '../../screens/income/add_income_screen.dart';

import '../constants/route_constants.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/add_expense/add_expense_screen.dart';
import '../../screens/expense_detail/expense_detail_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/settings/settings_screen.dart';

/// Wraps a screen in a fade + slight upward-slide transition, used for
/// every route so navigation feels consistent and polished throughout
/// the app instead of the platform's default abrupt push.
CustomTransitionPage<void> _buildPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeOut);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.03),
        end: Offset.zero,
      ).animate(fade);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}

final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      pageBuilder: (context, state) => _buildPage(const SplashScreen()),
    ),
    GoRoute(
      path: RouteConstants.home,
      pageBuilder: (context, state) => _buildPage(const HomeScreen()),
    ),
    GoRoute(
      path: RouteConstants.addExpense,
      pageBuilder: (context, state) => _buildPage(const AddExpenseScreen()),
    ),
    GoRoute(
      path: '${RouteConstants.editExpense}/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(AddExpenseScreen(expenseId: id));
      },
    ),
    GoRoute(
      path: '${RouteConstants.expenseDetail}/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(ExpenseDetailScreen(expenseId: id));
      },
    ),
    GoRoute(
      path: RouteConstants.statistics,
      pageBuilder: (context, state) => _buildPage(const StatisticsScreen()),
    ),
    GoRoute(
      path: RouteConstants.settings,
      pageBuilder: (context, state) => _buildPage(const SettingsScreen()),
    ),
    GoRoute(
      path: RouteConstants.income,
      pageBuilder: (context, state) => _buildPage(const IncomeScreen()),
    ),
    GoRoute(
      path: RouteConstants.addIncome,
      pageBuilder: (context, state) => _buildPage(const AddIncomeScreen()),
    ),
    GoRoute(
      path: '${RouteConstants.editIncome}/:id',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return _buildPage(AddIncomeScreen(incomeId: id));
      },
    ),
  ],
);