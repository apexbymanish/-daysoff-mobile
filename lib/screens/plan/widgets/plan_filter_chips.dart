import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/country_flag.dart';
import '../../../providers/preferences_provider.dart';
import '../../../providers/selection_provider.dart';
import '../../../router/app_router.dart';
import '../../../widgets/preferences_editor_sheet.dart';

/// Horizontal chip row reflecting the plan prefs; each chip opens its editor.
class PlanFilterChips extends ConsumerWidget {
  const PlanFilterChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final weekend = ref.watch(weekendProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          ActionChip(
            avatar: Text(countryFlag(country)),
            label: Text(country),
            onPressed: () => context.push(AppRoutes.countryPicker),
          ),
          ActionChip(
            label: Text('$year'),
            onPressed: () => _showYearDialog(context, ref, year),
          ),
          ActionChip(
            label: Text('${formatWeekend(weekend)} off'),
            onPressed: () => showPreferencesEditor(context),
          ),
          ActionChip(
            label: Text('$budget days'),
            onPressed: () => showPreferencesEditor(context),
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
