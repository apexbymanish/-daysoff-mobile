import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../api/models/holiday.dart';
import '../../providers/holidays_provider.dart';
import '../../theme/colors.dart';
import 'widgets/days_until_banner.dart';
import 'widgets/holiday_card.dart';
import 'widgets/month_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // Hardcoded for the scaffold — country picker + year stepper land in a
  // later session. KR 2026 matches the Stitch sample data throughout.
  static const _country = 'KR';
  static const _year = 2026;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holidaysAsync =
        ref.watch(holidaysProvider(const HolidaysQuery(country: _country, year: _year)));

    return Scaffold(
      body: SafeArea(
        child: holidaysAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => _ErrorState(
            message: err.toString(),
            onRetry: () => ref.invalidate(
              holidaysProvider(const HolidaysQuery(country: _country, year: _year)),
            ),
          ),
          data: (response) => _HolidaysList(holidays: response.holidays),
        ),
      ),
    );
  }
}

class _HolidaysList extends StatelessWidget {
  const _HolidaysList({required this.holidays});

  final List<Holiday> holidays;

  @override
  Widget build(BuildContext context) {
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

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          elevation: 0,
          backgroundColor: DaysoffColors.creamSoft,
          title: Row(
            children: [
              _CountryChip(code: 'KR', flag: '🇰🇷'),
              const SizedBox(width: 12),
              const Text('2026',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
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
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

class _CountryChip extends StatelessWidget {
  const _CountryChip({required this.code, required this.flag});
  final String code;
  final String flag;

  @override
  Widget build(BuildContext context) {
    return Container(
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
