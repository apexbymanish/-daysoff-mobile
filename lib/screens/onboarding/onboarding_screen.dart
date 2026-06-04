import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../theme/colors.dart';

/// Value-first welcome. "Get started" enters the app immediately; the
/// secondary action lets the user choose their work country first.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DaysoffColors.brandTeal, DaysoffColors.sage],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(flex: 2),
                const Text('daysoff',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: DaysoffColors.cream)),
                const SizedBox(height: 16),
                const Text(
                  'Find the longest break for the fewest days off.',
                  style: TextStyle(
                      fontSize: 22,
                      height: 1.3,
                      color: DaysoffColors.creamSoft,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Built for 연차, बिदा, 有給休暇, and every other word for it.',
                  style: TextStyle(fontSize: 14, color: DaysoffColors.creamSoft),
                ),
                const Spacer(flex: 3),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: DaysoffColors.cream,
                      foregroundColor: DaysoffColors.brandTealDark,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: () => context.go(AppRoutes.home),
                    child: const Text('Get started',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.countryPicker),
                    child: const Text('Choose your work country',
                        style: TextStyle(color: DaysoffColors.cream)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
