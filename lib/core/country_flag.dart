/// Returns the emoji flag for an ISO-3166 alpha-2 country code by mapping
/// each letter to its Regional Indicator Symbol. Falls back to 🌐 for
/// anything that isn't exactly two ASCII letters.
String countryFlag(String code) {
  if (code.length != 2) return '🌐';
  final up = code.toUpperCase();
  final a = up.codeUnitAt(0);
  final b = up.codeUnitAt(1);
  const aCode = 0x41; // 'A'
  const zCode = 0x5A; // 'Z'
  if (a < aCode || a > zCode || b < aCode || b > zCode) return '🌐';
  const base = 0x1F1E6; // Regional Indicator Symbol Letter A
  return String.fromCharCodes([base + (a - aCode), base + (b - aCode)]);
}
