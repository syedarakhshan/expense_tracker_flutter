import 'package:go_router/go_router.dart';

import '../constants/route_constants.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/add_expense/add_expense_screen.dart';
import '../../screens/expense_detail/expense_detail_screen.dart';
import '../../screens/statistics/statistics_screen.dart';
import '../../screens/settings/settings_screen.dart';

/// App-wide GoRouter configuration.
/// Declared as a plain top-level instance for now; in Step 5 we may
/// wrap this in a Riverpod provider if we need router-level state
/// (e.g. redirect logic based on auth or onboarding status).
final GoRouter appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: RouteConstants.addExpense,
      builder: (context, state) => const AddExpenseScreen(),
    ),
    GoRoute(
      // Used when editing: /edit-expense/:id
      path: '${RouteConstants.editExpense}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddExpenseScreen(expenseId: id);
      },
    ),
    GoRoute(
      // /expense-detail/:id
      path: '${RouteConstants.expenseDetail}/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ExpenseDetailScreen(expenseId: id);
      },
    ),
    GoRoute(
      path: RouteConstants.statistics,
      builder: (context, state) => const StatisticsScreen(),
    ),
    GoRoute(
      path: RouteConstants.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);