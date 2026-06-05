import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/holiday.dart';
import '../../api/models/plan_trip.dart';
import '../../providers/holidays_provider.dart';
import '../../providers/holidays_view_provider.dart';
import '../../providers/plan_provider.dart';
import '../../providers/preferences_provider.dart';
import '../../providers/selection_provider.dart';
import '../../router/app_router.dart';
import '../../theme/colors.dart';
import 'widgets/day_detail_sheet.dart';
import 'widgets/holiday_calendar_view.dart';
import 'widgets/holiday_card.dart';
import 'widgets/month_section.dart';
import 'widgets/next_break_hero.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final holidaysAsync =
        ref.watch(holidaysProvider(HolidaysQuery(country: country, year: year)));

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: holidaysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(
              holidaysProvider(HolidaysQuery(country: country, year: year)),
            ),
          ),
          data: (response) => _HolidaysList(
            holidays: response.holidays,
            country: country,
            year: year,
          ),
        ),
      ),
    );
  }
}

class _HolidaysList extends ConsumerWidget {
  const _HolidaysList({
    required this.holidays,
    required this.country,
    required this.year,
  });

  final List<Holiday> holidays;
  final String country;
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (holidays.isEmpty) {
      return const _EmptyState();
    }

    final now = DateTime.now();
    final lower = DateTime(now.year, now.month, now.day);

    final upcoming =
        holidays.where((h) => !h.date.isBefore(lower)).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    // Watch the plan to compute the longest-break cap.
    final budget = ref.watch(ptoBudgetProvider);
    final lenRange = ref.watch(breakLengthProvider);
    final weekend = ref.watch(weekendProvider);
    final planAsync = ref.watch(planProvider(PlanQuery(
      country: country,
      year: year,
      budget: budget,
      minLength: lenRange.min,
      maxLength: lenRange.max,
      workweek: weekend,
    )));

    DateTime cap = DateTime(year, 12, 31);
    planAsync.whenData((resp) {
      PlanTrip? longest;
      for (final list in resp.resultsByLength.values) {
        for (final t in list) {
          if (longest == null || t.breakLength > longest.breakLength) {
            longest = t;
          }
        }
      }
      if (longest != null) cap = longest.breakEnd;
    });

    // Window the list to [today .. cap] for the month sections.
    final windowed = holidays
        .where((h) => !h.date.isBefore(lower) && !h.date.isAfter(cap))
        .toList();

    final byMonth = <int, List<Holiday>>{};
    for (final h in windowed) {
      byMonth.putIfAbsent(h.date.month, () => []).add(h);
    }
    final months = byMonth.keys.toList()..sort();

    final view = ref.watch(holidaysViewProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: const Color(0xFFF9F9F9),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: const Color(0xFFC0C8C8), // outline-variant
            ),
          ),
          title: Row(
            children: [
              // Globe icon → country picker
              IconButton(
                icon: const Icon(Icons.language, color: DaysoffColors.brandTeal),
                onPressed: () => context.push(AppRoutes.countryPicker),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 4),
              // "daysoff" wordmark
              const Text(
                'daysoff',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: DaysoffColors.brandTeal,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 12),
              // Year stepper
              _YearStepper(year: year),
            ],
          ),
          actions: [
            // Single toggle: shows calendar_today in list view, view_agenda in calendar view
            if (view == HolidaysView.list)
              IconButton(
                key: const Key('toggle-calendar'),
                icon: const Icon(Icons.calendar_today,
                    color: DaysoffColors.brandTeal),
                onPressed: () =>
                    ref.read(holidaysViewProvider.notifier).state =
                        HolidaysView.calendar,
              )
            else
              IconButton(
                key: const Key('toggle-list'),
                icon: const Icon(Icons.view_agenda_outlined,
                    color: DaysoffColors.brandTeal),
                onPressed: () {
                  ref.read(calendarFocusProvider.notifier).state = null;
                  ref.read(holidaysViewProvider.notifier).state =
                      HolidaysView.list;
                },
              ),
            // Bookmark → saved
            IconButton(
              icon: const Icon(Icons.bookmark_border),
              onPressed: () => context.push(AppRoutes.saved),
            ),
          ],
        ),
        if (view == HolidaysView.calendar)
          SliverToBoxAdapter(
            child: HolidayCalendarView(holidays: holidays, year: year),
          )
        else ...[
          if (upcoming.isNotEmpty)
            SliverToBoxAdapter(
              child: NextBreakHero(
                next: upcoming.first,
                onTap: () => context.push(AppRoutes.destinations),
                onSeeDetails: () => showDayDetailSheet(
                    context, upcoming.first.date, [upcoming.first], null),
              ),
            ),
          if (windowed.isEmpty)
            const SliverToBoxAdapter(child: _NoUpcomingState())
          else
            for (final month in months) ...[
              SliverToBoxAdapter(child: MonthSection(month: month)),
              SliverList.builder(
                itemCount: byMonth[month]!.length,
                itemBuilder: (context, index) {
                  final h = byMonth[month]![index];
                  return HolidayCard(
                    holiday: h,
                    onTap: () {
                      ref.read(calendarFocusProvider.notifier).state = h.date;
                      ref.read(holidaysViewProvider.notifier).state =
                          HolidaysView.calendar;
                    },
                  );
                },
              ),
            ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _YearStepper extends ConsumerWidget {
  const _YearStepper({required this.year});
  final int year;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              ref.read(selectedYearProvider.notifier).state = year - 1,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Text(
          '$year',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: DaysoffColors.brandTeal,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () =>
              ref.read(selectedYearProvider.notifier).state = year + 1,
          iconSize: 20,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}

class _NoUpcomingState extends StatelessWidget {
  const _NoUpcomingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Text(
        'No upcoming holidays.',
        style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No holidays for this year.',
          style: TextStyle(fontSize: 16, color: DaysoffColors.neutral700),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Couldn't load holidays.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: DaysoffColors.neutral500, fontSize: 13),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
