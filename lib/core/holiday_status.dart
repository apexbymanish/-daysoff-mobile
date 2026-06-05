/// Maps weekday tokens (matching the API workweek tokens) to DateTime weekday ints.
const kWeekdayInts = {
  'mon': DateTime.monday,
  'tue': DateTime.tuesday,
  'wed': DateTime.wednesday,
  'thu': DateTime.thursday,
  'fri': DateTime.friday,
  'sat': DateTime.saturday,
  'sun': DateTime.sunday,
};

/// A holiday is "absorbed" when it falls on one of the user's weekly days off
/// (already a non-working day); otherwise it's a "free" extra day off.
bool isAbsorbed(DateTime date, List<String> weekend) {
  for (final key in weekend) {
    if (kWeekdayInts[key] == date.weekday) return true;
  }
  return false;
}
