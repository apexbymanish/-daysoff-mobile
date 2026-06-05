import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The two views available on the Plan screen.
enum PlanView { buffet, sandwich }

/// Tracks which plan view is currently selected.
final planViewProvider =
    StateProvider<PlanView>((ref) => PlanView.buffet);
