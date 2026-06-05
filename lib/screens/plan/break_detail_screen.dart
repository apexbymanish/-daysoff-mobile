import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../api/models/holiday.dart';
import '../../api/models/plan_trip.dart';
import '../../api/models/saved_break.dart';
import '../../core/break_days.dart';
import '../../providers/holidays_provider.dart';
import '../../providers/saved_breaks_provider.dart';
import '../../providers/selection_provider.dart';
import '../../theme/colors.dart';
import '../home/widgets/scenery.dart';

class BreakDetailScreen extends ConsumerWidget {
  const BreakDetailScreen({super.key, required this.trip});
  final PlanTrip trip;

  DateTime _d0(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final country = ref.watch(selectedCountryProvider);
    final year = ref.watch(selectedYearProvider);
    final holidaysAsync =
        ref.watch(holidaysProvider(HolidaysQuery(country: country, year: year)));

    final byDay = <DateTime, Holiday>{};
    holidaysAsync.maybeWhen(
      data: (resp) {
        for (final h in resp.holidays) {
          byDay[_d0(h.date)] = h;
        }
      },
      orElse: () {},
    );

    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }

    final rangeFmt = DateFormat('MMM d');
    final dayFmt = DateFormat('EEE MMM d');
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';

    void save() {
      ref.read(savedBreaksProvider.notifier).add(SavedBreak(
            id: 'break-${trip.breakStart.toIso8601String()}',
            label: '${trip.breakLength}-day break',
            start: trip.breakStart,
            end: trip.breakEnd,
            ptoCost: trip.ptoCost,
            kind: 'break',
          ));
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Saved')));
    }

    return Scaffold(
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: DaysoffColors.sage),
            icon: const Icon(Icons.bookmark_add_outlined),
            label: const Text('Save this break'),
            onPressed: save,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            foregroundColor: Colors.white,
            backgroundColor: DaysoffColors.brandTeal,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Break Details'),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    sceneryForDate(trip.breakStart),
                    fit: BoxFit.cover,
                    errorBuilder: (_, e, s) =>
                        const ColoredBox(color: DaysoffColors.brandTeal),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.black87],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${trip.breakLength}-day break',
                        style: const TextStyle(
                            fontSize: 28, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      '${rangeFmt.format(trip.breakStart)} – ${rangeFmt.format(trip.breakEnd)}'
                      '${anchor.isEmpty ? '' : '  ·  anchored on $anchor'}',
                      style: const TextStyle(color: DaysoffColors.neutral700),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: DaysoffColors.sage.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 18, color: DaysoffColors.brandTeal),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${trip.ptoCost} PTO day${trip.ptoCost == 1 ? '' : 's'} → '
                              '${trip.breakLength} days off',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('DAY-BY-DAY',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8,
                            color: DaysoffColors.neutral500)),
                    const SizedBox(height: 4),
                    for (final d in days)
                      _DayRow(
                        day: d,
                        fmt: dayFmt,
                        kind: classifyBreakDay(d, trip.ptoDates),
                        holiday: byDay[_d0(d)],
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.fmt,
    required this.kind,
    this.holiday,
  });

  final DateTime day;
  final DateFormat fmt;
  final BreakDayKind kind;
  final Holiday? holiday;

  @override
  Widget build(BuildContext context) {
    final (String label, Color color) = switch (kind) {
      BreakDayKind.pto => ('PTO', DaysoffColors.sage),
      BreakDayKind.weekend => ('Weekend', DaysoffColors.neutral300),
      BreakDayKind.holiday => (holiday?.name ?? 'Holiday', DaysoffColors.peach),
    };
    final h = holiday;
    final native = kind == BreakDayKind.holiday &&
            h != null &&
            h.nameLocal != null &&
            h.nameLocal != h.name
        ? h.nameLocal
        : null;

    return Container(
      key: const ValueKey('break-day-row'),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DaysoffColors.neutral100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fmt.format(day)),
                if (native != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(native,
                        style: const TextStyle(
                            fontSize: 12, color: DaysoffColors.neutral500)),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: DaysoffColors.neutral900)),
          ),
        ],
      ),
    );
  }
}
