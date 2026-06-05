import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/plan_response.dart';
import '../../api/models/plan_trip.dart';
import '../../providers/plan_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/selection_provider.dart';
import '../../widgets/preferences_editor_sheet.dart';
import '../../router/app_router.dart';
import '../../theme/colors.dart';
import '../../core/plan_value.dart';
import 'widgets/break_card.dart';
import 'widgets/plan_filter_chips.dart';
import 'widgets/best_value_banner.dart';

class PlanScreen extends ConsumerWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final budget = ref.watch(ptoBudgetProvider);
    final range = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    final query = PlanQuery(
      country: country,
      year: year,
      budget: budget,
      minLength: range.min,
      maxLength: range.max,
      workweek: weekend,
    );
    final planAsync = ref.watch(planProvider(query));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan your year'),
        actions: [
          TextButton.icon(
            onPressed: () => showPreferencesEditor(context),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Adjust'),
          ),
        ],
      ),
      body: SafeArea(
        child: planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _PlanError(onRetry: () => ref.invalidate(planProvider(query))),
          data: (resp) => _Buffet(response: resp),
        ),
      ),
    );
  }
}

class _Buffet extends StatelessWidget {
  const _Buffet({required this.response});
  final PlanResponse response;

  /// Best (first) trip of each length, ordered by ascending length.
  List<PlanTrip> get _bestPerLength {
    final lengths = response.resultsByLength.keys
        .map(int.parse)
        .toList()
      ..sort();
    return [
      for (final len in lengths)
        if (response.resultsByLength['$len']!.isNotEmpty)
          response.resultsByLength['$len']!.first,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final trips = _bestPerLength;
    if (trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No breaks fit this budget. Try increasing it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700)),
        ),
      );
    }
    final best = bestValueTrip(trips);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      children: [
        const PlanFilterChips(),
        if (best != null) BestValueBanner(trip: best),
        for (final t in trips)
          BreakCard(
            trip: t,
            onTap: () => context.push(AppRoutes.breakDetail, extra: t),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _PlanError extends StatelessWidget {
  const _PlanError({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("Couldn't build your plan.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
