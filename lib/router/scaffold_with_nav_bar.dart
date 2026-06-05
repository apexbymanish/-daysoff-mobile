import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/colors.dart';
import '../theme/typography.dart';

/// Bottom-navigation shell hosting the three primary branches.
///
/// Uses a custom tab bar instead of the Material [NavigationBar], matching the
/// Stitch 6.7 design: selected tab shows a brandTeal pill, unselected tabs use
/// neutral700. Labels are uppercase via [labelCaps].
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  static const _tabs = [
    _TabItem(icon: Icons.calendar_today, label: 'HOLIDAYS'),
    _TabItem(icon: Icons.auto_awesome, label: 'PLAN'),
    _TabItem(icon: Icons.settings, label: 'SETTINGS'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 80,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: DaysoffColors.outlineVariant, width: 1),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final tab = _tabs[index];
              final isSelected = navigationShell.currentIndex == index;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => navigationShell.goBranch(
                    index,
                    initialLocation: index == navigationShell.currentIndex,
                  ),
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? DaysoffColors.brandTeal.withValues(alpha: 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tab.icon,
                            size: 22,
                            color: isSelected
                                ? DaysoffColors.brandTeal
                                : DaysoffColors.neutral700,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.label,
                            style: labelCaps(
                              fontSize: 10,
                              color: isSelected
                                  ? DaysoffColors.brandTeal
                                  : DaysoffColors.neutral700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
