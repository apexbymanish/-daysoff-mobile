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
import '../home/widgets/scenery.dart';
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
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Adjust preferences',
            onPressed: () => showPreferencesEditor(context),
          ),
        ],
      ),
      body: SafeArea(
        child: planAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) =>
              _PlanError(onRetry: () => ref.invalidate(planProvider(query))),
          data: (resp) => _Buffet(response: resp),
        ),
      ),
    );
  }
}

class _Buffet extends StatefulWidget {
  const _Buffet({required this.response});
  final PlanResponse response;

  @override
  State<_Buffet> createState() => _BuffetState();
}

class _BuffetState extends State<_Buffet> {
  late final List<PlanTrip> _trips;
  late final PlanTrip? _best;
  late final int _initialPage;
  late final PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _trips = _bestPerLength(widget.response);
    _best = bestValueTrip(_trips);
    _initialPage = _best != null ? _trips.indexOf(_best) : 0;
    _currentPage = _initialPage;
    _pageController =
        PageController(viewportFraction: 0.85, initialPage: _initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Best (first) trip of each length, ordered by ascending length.
  static List<PlanTrip> _bestPerLength(PlanResponse response) {
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
    if (_trips.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'No breaks fit this budget. Try increasing it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700),
          ),
        ),
      );
    }

    return ListView(
      children: [
        // Filter chips
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: PlanFilterChips(),
        ),
        // Best value banner
        if (_best != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BestValueBanner(trip: _best),
          ),
        const SizedBox(height: 16),
        // Carousel
        SizedBox(
          height: 340,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _trips.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final trip = _trips[i];
              final isBest = trip == _best;
              final isFocused = i == _currentPage;
              return AnimatedScale(
                scale: isFocused ? 1.0 : 0.93,
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: isFocused ? 1.0 : 0.6,
                  duration: const Duration(milliseconds: 250),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BreakCard(
                      trip: trip,
                      isBestValue: isBest,
                      onTap: () =>
                          context.push(AppRoutes.breakDetail, extra: trip),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < _trips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: i == _currentPage ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: i == _currentPage
                      ? DaysoffColors.brandTeal
                      : DaysoffColors.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 24),
        // Balance banner
        _BalanceBanner(response: widget.response),
        const SizedBox(height: 32),
      ],
    );
  }
}

class _BalanceBanner extends StatelessWidget {
  const _BalanceBanner({required this.response});
  final PlanResponse response;

  @override
  Widget build(BuildContext context) {
    final year = response.year;
    final budget = response.budget;
    final sceneryPath = sceneryForDate(DateTime(year, 1, 1));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: DaysoffColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: DaysoffColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: [
            BoxShadow(
              color: DaysoffColors.brandTeal.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Scenery thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.asset(
                  sceneryPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: DaysoffColors.brandTeal,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance: $budget days left',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: DaysoffColors.brandTeal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Optimized for $year. These plans maximize long weekends while keeping your PTO budget intact.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: DaysoffColors.neutral700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
          const Text(
            "Couldn't build your plan.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
