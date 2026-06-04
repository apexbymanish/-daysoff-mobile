/// The role a single day plays inside a contiguous break.
enum BreakDayKind { pto, weekend, holiday }

const _weekend = {DateTime.saturday, DateTime.sunday};

/// Within a break every day is off; classify it as a PTO day, a weekend day,
/// or (by elimination) the anchoring holiday.
BreakDayKind classifyBreakDay(DateTime day, List<DateTime> ptoDates) {
  final isPto = ptoDates.any((p) =>
      p.year == day.year && p.month == day.month && p.day == day.day);
  if (isPto) return BreakDayKind.pto;
  if (_weekend.contains(day.weekday)) return BreakDayKind.weekend;
  return BreakDayKind.holiday;
}
