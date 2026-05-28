import 'package:go_router/go_router.dart';

import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/plan/plan_screen.dart';
import '../screens/sandwich/sandwich_screen.dart';
import '../screens/settings/settings_screen.dart';

/// Top-level routes.
///
/// Onboarding is the first surface per the Stitch spec, but for this
/// scaffold we land directly on Home so the /v1/holidays integration
/// is exercised end-to-end without needing Firebase Auth set up.
class AppRoutes {
  AppRoutes._();
  static const home = '/';
  static const onboarding = '/onboarding';
  static const plan = '/plan';
  static const sandwich = '/sandwich';
  static const settings = '/settings';
}

final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.plan,
      builder: (context, state) => const PlanScreen(),
    ),
    GoRoute(
      path: AppRoutes.sandwich,
      builder: (context, state) => const SandwichScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
