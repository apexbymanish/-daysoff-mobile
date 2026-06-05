import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/models/holiday.dart';
import '../../providers/holidays_provider.dart';
import '../../providers/holidays_view_provider.dart';
import '../../providers/selection_provider.dart';
import '../../router/app_router.dart';
import '../../core/country_flag.dart';
import '../../theme/colors.dart';
import 'widgets/days_until_banner.dart';
import 'widgets/holiday_calendar_view.dart';
import 'widgets/holiday_card.dart';
import 'widgets/month_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final holidaysAsync =
        ref.watch(holidaysProvider(HolidaysQuery(country: country, year: year)));

    return Scaffold(
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
    final upcoming =
        holidays.where((h) => !h.date.isBefore(DateTime(now.year, now.month, now.day))).toList()
          ..sort((a, b) => a.date.compareTo(b.date));

    final byMonth = <int, List<Holiday>>{};
    for (final h in holidays) {
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
          backgroundColor: DaysoffColors.creamSoft,
          title: Row(
            children: [
              _TappableCountryChip(
                code: country,
                flag: countryFlag(country),
                onTap: () => context.push(AppRoutes.countryPicker),
              ),
              const SizedBox(width: 12),
              _YearStepper(year: year),
            ],
          ),
          actions: [
            IconButton(
              key: const Key('toggle-list'),
              icon: Icon(Icons.view_agenda_outlined,
                  color: view == HolidaysView.list
                      ? DaysoffColors.brandTeal
                      : DaysoffColors.neutral500),
              onPressed: () =>
                  ref.read(holidaysViewProvider.notifier).state = HolidaysView.list,
            ),
            IconButton(
              key: const Key('toggle-calendar'),
              icon: Icon(Icons.calendar_month_outlined,
                  color: view == HolidaysView.calendar
                      ? DaysoffColors.brandTeal
                      : DaysoffColors.neutral500),
              onPressed: () =>
                  ref.read(holidaysViewProvider.notifier).state = HolidaysView.calendar,
            ),
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
              child: DaysUntilBanner(next: upcoming.first),
            ),
          for (final month in months) ...[
            SliverToBoxAdapter(child: MonthSection(month: month)),
            SliverList.builder(
              itemCount: byMonth[month]!.length,
              itemBuilder: (context, index) =>
                  HolidayCard(holiday: byMonth[month]![index]),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _TappableCountryChip extends StatelessWidget {
  const _TappableCountryChip({
    required this.code,
    required this.flag,
    required this.onTap,
  });
  final String code;
  final String flag;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: DaysoffColors.cream,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DaysoffColors.neutral300, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(code, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
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
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
