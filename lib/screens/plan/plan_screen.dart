import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../api/models/plan_response.dart';
import '../../api/models/plan_trip.dart';
import '../../providers/plan_provider.dart';
import '../../providers/plan_view_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/sandwiches_provider.dart';
import '../../providers/selection_provider.dart';
import '../../widgets/preferences_editor_sheet.dart';
import '../../router/app_router.dart';
import '../../theme/colors.dart';
import '../../core/plan_value.dart';
import '../home/widgets/scenery.dart';
import '../sandwich/widgets/efficiency_insight.dart';
import '../sandwich/widgets/sandwich_card.dart';
import 'widgets/break_card.dart';
import 'widgets/month_strip.dart';
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
    final view = ref.watch(planViewProvider);
    final month = ref.watch(planMonthProvider);

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Filter chips (visible in both views)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: PlanFilterChips(),
            ),
            // Segmented control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: _ViewToggle(
                selected: view,
                onChanged: (v) =>
                    ref.read(planViewProvider.notifier).state = v,
              ),
            ),
            // Month filter strip (visible in both views)
            const MonthStrip(),
            // Content area
            Expanded(
              child: view == PlanView.buffet
                  ? _BuffetView(
                      country: country,
                      year: year,
                      budget: budget,
                      range: range,
                      weekend: weekend,
                      ref: ref,
                      month: month,
                    )
                  : _SandwichView(
                      country: country,
                      year: year,
                      weekend: weekend,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segmented control ──────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  const _ViewToggle({required this.selected, required this.onChanged});
  final PlanView selected;
  final ValueChanged<PlanView> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: DaysoffColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'Length buffet',
            isActive: selected == PlanView.buffet,
            onTap: () => onChanged(PlanView.buffet),
          ),
          _Segment(
            label: 'Sandwich days',
            isActive: selected == PlanView.sandwich,
            onTap: () => onChanged(PlanView.sandwich),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.isActive,
    required this.onTap,
  });
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: DaysoffColors.outlineVariant.withValues(alpha: 0.3))
                : null,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive
                  ? DaysoffColors.brandTeal
                  : DaysoffColors.neutral700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Buffet view (delegates to the old _Buffet widget) ─────────────────────────

class _BuffetView extends StatelessWidget {
  const _BuffetView({
    required this.country,
    required this.year,
    required this.budget,
    required this.range,
    required this.weekend,
    required this.ref,
    required this.month,
  });
  final String country;
  final int year;
  final int budget;
  final BreakLengthRange range;
  final List<String> weekend;
  final WidgetRef ref;
  final int? month;

  @override
  Widget build(BuildContext context) {
    final query = PlanQuery(
      country: country,
      year: year,
      budget: budget,
      minLength: range.min,
      maxLength: range.max,
      workweek: weekend,
    );
    final planAsync = ref.watch(planProvider(query));
    return planAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          _PlanError(onRetry: () => ref.invalidate(planProvider(query))),
      data: (resp) => _Buffet(response: resp, month: month),
    );
  }
}

// ── Sandwich view ──────────────────────────────────────────────────────────────

class _SandwichView extends ConsumerWidget {
  const _SandwichView({
    required this.country,
    required this.year,
    required this.weekend,
  });
  final String country;
  final int year;
  final List<String> weekend;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(planMonthProvider);
    final query =
        SandwichesQuery(country: country, year: year, workweek: weekend);
    final async = ref.watch(sandwichesProvider(query));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load sandwich days.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => ref.invalidate(sandwichesProvider(query)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
      data: (resp) {
        if (resp.sandwiches.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No sandwich days this year.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, color: DaysoffColors.neutral700),
              ),
            ),
          );
        }
        final filtered = month == null
            ? resp.sandwiches
            : resp.sandwiches
                .where((s) => s.ptoDate.month == month)
                .toList();
        if (filtered.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                'No sandwich days in ${_monthName(month!)}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 16, color: DaysoffColors.neutral700),
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Single workdays wedged between days off — take one, gain a long weekend.',
                style: TextStyle(
                    fontSize: 14, color: DaysoffColors.neutral700, height: 1.5),
              ),
            ),
            for (final s in filtered) SandwichCard(record: s),
            const SizedBox(height: 8),
            EfficiencyInsight(records: filtered),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

String _monthName(int m) => DateFormat('MMMM').format(DateTime(2000, m));

// ── Buffet (carousel) widget ───────────────────────────────────────────────────

class _Buffet extends StatefulWidget {
  const _Buffet({required this.response, required this.month});
  final PlanResponse response;
  final int? month;

  @override
  State<_Buffet> createState() => _BuffetState();
}

class _BuffetState extends State<_Buffet> {
  late List<PlanTrip> _trips;
  late PlanTrip? _best;
  late final PageController _pageController;
  late int _currentPage;

  void _recompute() {
    _trips = _bestPerLength(widget.response, widget.month);
    _best = bestValueTrip(_trips);
  }

  @override
  void initState() {
    super.initState();
    _recompute();
    // Open on the first (longest) option; the best-value badge still marks
    // whichever option is the best value, wherever it sits.
    _currentPage = 0;
    _pageController =
        PageController(viewportFraction: 0.85, initialPage: 0);
  }

  @override
  void didUpdateWidget(_Buffet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.month != widget.month ||
        oldWidget.response != widget.response) {
      setState(_recompute);
      _currentPage = 0;
      _pageController.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// The best break for each length, filtered by [month] (null = all),
  /// sorted **longest-first**, capped at the top 8 options.
  static List<PlanTrip> _bestPerLength(PlanResponse response, int? month) {
    final best = [
      for (final list in response.resultsByLength.values)
        if (list.isNotEmpty) list.first,
    ]
        .where((t) => month == null || t.breakStart.month == month)
        .toList()
      ..sort((a, b) {
        final byLength = b.breakLength.compareTo(a.breakLength); // longest first
        if (byLength != 0) return byLength;
        final byPto = a.ptoCost.compareTo(b.ptoCost); // then fewer PTO
        if (byPto != 0) return byPto;
        return a.breakStart.compareTo(b.breakStart); // then earliest
      });
    return best.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_trips.isEmpty) {
      final emptyMsg = widget.month != null
          ? 'No break options in ${_monthName(widget.month!)}.'
          : 'No breaks fit this budget. Try increasing it.';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMsg,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16, color: DaysoffColors.neutral700),
          ),
        ),
      );
    }

    final best = _best;
    return ListView(
      children: [
        // Best value banner
        if (best != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: BestValueBanner(trip: best),
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
              final isBest = trip == best;
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
