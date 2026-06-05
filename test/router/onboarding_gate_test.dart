import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:daysoff_mobile/api/models/holidays_response.dart';
import 'package:daysoff_mobile/app.dart';
import 'package:daysoff_mobile/core/storage_keys.dart';
import 'package:daysoff_mobile/providers/holidays_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the path_provider channel so GetStorage.init() works in widget tests
  // (path_provider plugin is not registered in the Dart test runner).
  const pathProviderChannel =
      MethodChannel('plugins.flutter.io/path_provider');
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return Directory.systemTemp.path;
      }
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
    storageReady = false; // reset so other test files stay unaffected
  });

  setUp(() async {
    await GetStorage.init();
    markStorageReady();
    await GetStorage().erase();
  });

  tearDown(() {
    storageReady = false; // isolate each test
  });

  testWidgets('when onboarding already seen, app skips Welcome to Home',
      (tester) async {
    GetStorage().write(StorageKeys.onboardingSeen, true);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        holidaysProvider(const HolidaysQuery(country: 'KR', year: 2026))
            .overrideWith((ref) async => const HolidaysResponse(
                  country: 'KR', year: 2026, count: 0, holidays: [],
                )),
      ],
      child: const DaysoffApp(),
    ));
    await tester.pumpAndSettle();

    // No Welcome CTA — we're on Home (inside the nav shell).
    expect(find.text('Get started'), findsNothing);
    // Custom 3-tab bar renders with uppercase labels.
    expect(find.text('HOLIDAYS'), findsWidgets);
  });
}
