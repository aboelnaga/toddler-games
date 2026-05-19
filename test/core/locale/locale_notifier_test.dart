import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/locale/locale_notifier.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('localeProvider', () {
    test('derives ar-EG by default', () {
      final locale = container.read(localeProvider);
      expect(locale, const Locale('ar', 'EG'));
    });

    test('reflects settings changes', () async {
      await container.read(settingsProvider.notifier).setLocale('en');
      final locale = container.read(localeProvider);
      expect(locale, const Locale('en'));
    });

    test('falls back to default for unknown locale id', () async {
      await container.read(settingsProvider.notifier).setLocale('fr');
      final locale = container.read(localeProvider);
      expect(locale, SupportedLocales.defaultLocale);
    });
  });
}
