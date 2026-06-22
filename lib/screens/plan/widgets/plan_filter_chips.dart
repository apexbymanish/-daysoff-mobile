import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country_flag.dart';
import '../../../providers/preferences_provider.dart';
import '../../../providers/selection_provider.dart';
import '../../../router/app_router.dart';
import '../../../theme/colors.dart';
import '../../../widgets/preferences_editor_sheet.dart';

/// Horizontal chip row reflecting the plan prefs; each chip opens its editor.
/// Restyled as white pills with [DaysoffColors.outlineVariant] border + soft shadow.
class PlanFilterChips extends ConsumerWidget {
  const PlanFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final weekend = ref.watch(weekendProvider);
    final range = ref.watch(breakLengthProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(
            onTap: () => context.push(AppRoutes.countryPicker),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(countryFlag(country)),
                const SizedBox(width: 6),
                Text(
                  country,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          _Chip(
            onTap: () => _showYearDialog(context, ref, year),
            child: Text(
              '$year',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          _Chip(
            onTap: () => showPreferencesEditor(context),
            child: Text(
              '${formatWeekend(weekend)} off',
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          // PTO budget — olive bolt, matching the "X PTO" pills on cards.
          _Chip(
            onTap: () => showPreferencesEditor(context),
            background: DaysoffColors.oliveFixed.withValues(alpha: 0.5),
            border: DaysoffColors.oliveFixed,
            child: _LabeledValue(
              icon: Icons.bolt,
              iconColor: DaysoffColors.olive,
              label: '$budget days PTO',
            ),
          ),
          // Break-length range — teal beach, matching the break-length pill.
          // Mirrors the "Break length (3–10 days)" slider in the prefs sheet.
          _Chip(
            onTap: () => showPreferencesEditor(context),
            background: DaysoffColors.brandTeal.withValues(alpha: 0.08),
            border: DaysoffColors.brandTeal.withValues(alpha: 0.4),
            child: _LabeledValue(
              icon: Icons.beach_access,
              iconColor: DaysoffColors.brandTeal,
              label: '${range.min}–${range.max} day break',
            ),
          ),
        ],
      ),
    );
  }

  void _showYearDialog(BuildContext context, WidgetRef ref, int year) {
    var temp = year;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Year'),
        content: StatefulBuilder(
          builder: (context, setState) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                key: const Key('year_dec'),
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  temp -= 1;
                  ref.read(selectedYearProvider.notifier).state = temp;
                  setState(() {});
                },
              ),
              Text('$temp', style: const TextStyle(fontSize: 20)),
              IconButton(
                key: const Key('year_inc'),
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  temp += 1;
                  ref.read(selectedYearProvider.notifier).state = temp;
                  setState(() {});
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

/// A pill with a soft shadow. Defaults to white with an [outlineVariant]
/// border; pass [background]/[border] to tint it (used to colour-code the
/// PTO and break-length chips).
class _Chip extends StatelessWidget {
  const _Chip({
    required this.child,
    required this.onTap,
    this.background,
    this.border,
  });
  final Widget child;
  final VoidCallback onTap;
  final Color? background;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: background ?? Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border ?? DaysoffColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Leading icon + label, used to make the PTO and break-length chips
/// self-explanatory at a glance.
class _LabeledValue extends StatelessWidget {
  const _LabeledValue({
    required this.icon,
    required this.iconColor,
    required this.label,
  });
  final IconData icon;
  final Color iconColor;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
