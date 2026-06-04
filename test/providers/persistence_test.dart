import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:daysoff_mobile/core/storage_keys.dart';
import 'package:daysoff_mobile/providers/selection_provider.dart';
import 'package:daysoff_mobile/providers/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock the path_provider channel so GetStorage.init() works in unit tests
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

  test('selection seeds from storage and persists changes', () {
    GetStorage().write(StorageKeys.country, 'NP');
    GetStorage().write(StorageKeys.year, 2027);
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(selectedCountryProvider), 'NP');
    expect(c.read(selectedYearProvider), 2027);

    c.read(selectedCountryProvider.notifier).state = 'JP';
    expect(GetStorage().read(StorageKeys.country), 'JP');
  });

  test('theme seeds from storage and persists changes', () {
    GetStorage().write(StorageKeys.themeMode, 'dark');
    final c = ProviderContainer();
    addTearDown(c.dispose);

    expect(c.read(themeModeProvider), ThemeMode.dark);

    c.read(themeModeProvider.notifier).state = ThemeMode.system;
    expect(GetStorage().read(StorageKeys.themeMode), 'system');
  });

  test('defaults hold when storage is empty', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedCountryProvider), 'KR');
    expect(c.read(selectedYearProvider), 2026);
    expect(c.read(themeModeProvider), ThemeMode.light);
  });
}
