/// Bundled aspirational destination photos for the next-break hero.
const kScenery = [
  'assets/scenery/kyoto.jpg',
  'assets/scenery/alps.jpg',
  'assets/scenery/cinque_terre.jpg',
  'assets/scenery/marrakech.jpg',
];

/// Deterministic per-date pick so a given break always shows the same photo
/// but different breaks vary.
String sceneryForDate(DateTime d) =>
    kScenery[(d.month * 31 + d.day) % kScenery.length];
