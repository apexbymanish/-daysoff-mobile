import '../api/models/plan_trip.dart';

/// The trip with the best "days off per PTO day" value. A 0-PTO break counts
/// as half a PTO day so it ranks above any paid break. Ties break toward fewer
/// PTO days, then a longer break.
PlanTrip? bestValueTrip(List<PlanTrip> trips) {
  if (trips.isEmpty) return null;
  double ratio(PlanTrip t) => t.breakLength / (t.ptoCost == 0 ? 0.5 : t.ptoCost);
  PlanTrip best = trips.first;
  for (final t in trips.skip(1)) {
    final r = ratio(t);
    final rb = ratio(best);
    if (r > rb ||
        (r == rb && t.ptoCost < best.ptoCost) ||
        (r == rb && t.ptoCost == best.ptoCost && t.breakLength > best.breakLength)) {
      best = t;
    }
  }
  return best;
}
