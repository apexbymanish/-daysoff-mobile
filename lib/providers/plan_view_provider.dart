import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The two views available on the Plan screen.
enum PlanView { buffet, sandwich }

/// Tracks which plan view is currently selected.
final planViewProvider =
    StateProvider<PlanView>((ref) => PlanView.buffet);

/// Tracks the selected month filter on the Plan screen.
/// null = All months (default); 1–12 = January–December.
final planMonthProvider = StateProvider<int?>((ref) => null);
