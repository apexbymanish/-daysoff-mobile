import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which view the Holidays tab shows.
enum HolidaysView { list, calendar }

/// Session-only toggle; defaults to the timeline list.
final holidaysViewProvider =
    StateProvider<HolidaysView>((ref) => HolidaysView.list);
