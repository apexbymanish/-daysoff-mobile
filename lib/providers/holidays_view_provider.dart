import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which view the Holidays tab shows.
enum HolidaysView { list, calendar }

/// Session-only toggle; defaults to the timeline list.
final holidaysViewProvider =
    StateProvider<HolidaysView>((ref) => HolidaysView.list);

/// When non-null, the calendar view should open focused/selected on this date.
/// Cleared by [HolidayCalendarView] after it seeds its state.
final calendarFocusProvider = StateProvider<DateTime?>((ref) => null);
