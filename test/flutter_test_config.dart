import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Disable HTTP font fetching in tests. TextStyle.fontFamily is still set
  // correctly so assertions still pass; only glyph data is missing, which
  // is fine for widget tests.
  GoogleFonts.config.allowRuntimeFetching = false;

  // google_fonts throws an Exception (not a FlutterError) when a font isn't
  // bundled in assets. That exception surfaces as a post-test async error.
  // Override the test exception reporter to swallow just those errors.
  final originalReporter = reportTestException;
  reportTestException = (FlutterErrorDetails details, String testDescription) {
    final msg = details.exceptionAsString();
    if (msg.contains('GoogleFonts.config.allowRuntimeFetching is false')) {
      return; // benign: font glyph data not bundled; TextStyle family is correct
    }
    originalReporter(details, testDescription);
  };

  await testMain();
}
