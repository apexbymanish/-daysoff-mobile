import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../api/models/plan_trip.dart';
import '../../core/break_days.dart';
import '../../theme/colors.dart';

class BreakDetailScreen extends StatelessWidget {
  const BreakDetailScreen({super.key, required this.trip});
  final PlanTrip trip;

  String _kindFor(DateTime day) => switch (classifyBreakDay(day, trip.ptoDates)) {
        BreakDayKind.pto => 'PTO',
        BreakDayKind.weekend => 'Weekend',
        BreakDayKind.holiday => 'Holiday',
      };

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('EEE MMM d');
    final days = <DateTime>[];
    for (var d = trip.breakStart;
        !d.isAfter(trip.breakEnd);
        d = d.add(const Duration(days: 1))) {
      days.add(d);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Break detail')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('${trip.breakLength}-day break',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text('${trip.ptoCost} PTO day${trip.ptoCost == 1 ? '' : 's'} → '
                '${trip.breakLength} days off',
                style: const TextStyle(color: DaysoffColors.neutral700)),
            const SizedBox(height: 20),
            for (final d in days)
              Container(
                key: const ValueKey('break-day-row'),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: DaysoffColors.neutral100)),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(fmt.format(d))),
                    Text(_kindFor(d),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
