import 'package:flutter/widgets.dart';
import 'package:get_storage/get_storage.dart';
import 'package:go_router/go_router.dart';

import '../api/models/plan_trip.dart';
import '../core/storage_keys.dart';
import '../screens/country_picker/country_picker_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/plan/break_detail_screen.dart';
import '../screens/plan/plan_screen.dart';
import '../screens/sandwich/sandwich_screen.dart';
import '../screens/saved/saved_screen.dart';
import '../screens/settings/settings_screen.dart';
import 'scaffold_with_nav_bar.dart';

class AppRoutes {
  AppRoutes._();
  static const home = '/';
  static const onboarding = '/onboarding';
  static const plan = '/plan';
  static const breakDetail = '/plan/break';
  static const sandwich = '/sandwich';
  static const settings = '/settings';
  static const countryPicker = '/picker/country';
  static const saved = '/saved';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: AppRoutes.onboarding,
  redirect: (context, state) {
    // Only read storage when it has been initialized; otherwise treat as unseen
    // so that tests which skip GetStorage.init() work with the defaults.
    if (!storageReady) return null;
    final seen =
        GetStorage().read<bool>(StorageKeys.onboardingSeen) ?? false;
    final atOnboarding = state.matchedLocation == AppRoutes.onboarding;
    if (seen && atOnboarding) return AppRoutes.home; // skip Welcome on return visits
    if (!seen && !atOnboarding) return AppRoutes.onboarding; // force Welcome first-launch
    return null;
  },
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.plan,
            builder: (context, state) => const PlanScreen(),
            routes: [
              GoRoute(
                path: 'break', // full path: /plan/break
                parentNavigatorKey: _rootNavigatorKey, // full-screen over the nav bar
                builder: (context, state) =>
                    BreakDetailScreen(trip: state.extra! as PlanTrip),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.sandwich,
            builder: (context, state) => const SandwichScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ]),
      ],
    ),
    // Onboarding stays outside the shell (full-screen entry surface).
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (context, state) => const OnboardingScreen(),
    ),
    // Country picker — full-screen over the nav bar (root navigator).
    GoRoute(
      path: AppRoutes.countryPicker,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const CountryPickerScreen(),
    ),
    // Saved breaks — full-screen over the nav bar (root navigator).
    GoRoute(
      path: AppRoutes.saved,
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SavedScreen(),
    ),
  ],
);
