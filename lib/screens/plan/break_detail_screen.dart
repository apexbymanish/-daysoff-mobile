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

const _kSage = Color(0xFF8E9775);
const _kWarmCream = Color(0xFFFDFBF7);

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
    final anchor = trip.anchors.isNotEmpty ? trip.anchors.first : '';

    // Find the native name of the anchor: first holiday-kind day matched in byDay.
    String? anchorNative;
    for (final d in days) {
      final kind = classifyBreakDay(d, trip.ptoDates);
      if (kind == BreakDayKind.holiday) {
        final h = byDay[_d0(d)];
        if (h != null && h.nameLocal != null && h.nameLocal!.isNotEmpty) {
          anchorNative = h.nameLocal;
          break;
        }
      }
    }

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

    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = screenHeight > 0 ? screenHeight * 0.45 : 320.0;

    return Scaffold(
      backgroundColor: DaysoffColors.darkSurface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Break Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        leading: const BackButton(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              // ignore: use_build_context_synchronously
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: SizedBox(
            height: 56,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _kSage,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: save,
              child: const Text(
                'Save this break',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero ──────────────────────────────────────────────────────
            SizedBox(
              height: heroHeight,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    sceneryForDate(trip.breakStart),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const ColoredBox(color: DaysoffColors.brandTeal),
                  ),
                  // Scrim: transparent at top → darkSurface at bottom
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0x9914171A), // ~60% dark at mid
                          DaysoffColors.darkSurface,
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  // Hero content overlay
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Text(
                                '${trip.breakLength}-day break',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _kSage,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${trip.ptoCost} PTO',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                              children: [
                                TextSpan(
                                  text:
                                      '${rangeFmt.format(trip.breakStart)} – ${rangeFmt.format(trip.breakEnd)}'
                                      '${anchor.isEmpty ? '' : ' • anchored on '}',
                                ),
                                if (anchor.isNotEmpty)
                                  TextSpan(
                                    text: anchorNative != null
                                        ? '$anchor / $anchorNative'
                                        : anchor,
                                    style:
                                        const TextStyle(color: _kSage),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Dark body ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // DAY-BY-DAY header
                  const Text(
                    'DAY-BY-DAY',
                    style: TextStyle(
                      color: DaysoffColors.neutral500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Day rows
                  for (final d in days)
                    _DayRow(
                      day: d,
                      kind: classifyBreakDay(d, trip.ptoDates),
                      holiday: byDay[_d0(d)],
                      anchor: anchor,
                      isLast: d == days.last,
                    ),

                  const SizedBox(height: 24),

                  // Summary card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _kSage.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.event_available,
                            color: _kSage,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${trip.ptoCost} PTO day${trip.ptoCost == 1 ? '' : 's'} → ${trip.breakLength} days off',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Maximize your time with public holidays',
                                style: TextStyle(
                                  color: DaysoffColors.neutral500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.kind,
    required this.anchor,
    this.holiday,
    this.isLast = false,
  });

  final DateTime day;
  final BreakDayKind kind;
  final Holiday? holiday;
  final String anchor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE MMM d');

    final String overline;
    final String tagLabel;
    final Color tagBg;

    switch (kind) {
      case BreakDayKind.pto:
        overline = 'ORDINARY DAY';
        tagLabel = 'PTO';
        tagBg = _kSage.withValues(alpha: 0.12);
        break;
      case BreakDayKind.holiday:
        overline = 'FESTIVAL';
        final name = holiday?.name ?? (anchor.isNotEmpty ? anchor : 'Holiday');
        tagLabel = 'Holiday • $name';
        tagBg = DaysoffColors.koreaRed.withValues(alpha: 0.12);
        break;
      case BreakDayKind.weekend:
        overline = 'REST';
        tagLabel = 'Weekend';
        tagBg = DaysoffColors.brandTeal.withValues(alpha: 0.12);
        break;
    }

    return Container(
      key: const ValueKey('break-day-row'),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                fmt.format(day),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                overline,
                style: const TextStyle(
                  color: Color(0xFF8B9197),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: tagBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: switch (kind) {
                  BreakDayKind.pto => _kSage.withValues(alpha: 0.20),
                  BreakDayKind.holiday =>
                    DaysoffColors.koreaRed.withValues(alpha: 0.20),
                  BreakDayKind.weekend =>
                    DaysoffColors.brandTeal.withValues(alpha: 0.20),
                },
              ),
            ),
            child: Text(
              tagLabel,
              style: const TextStyle(
                color: _kWarmCream,
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
