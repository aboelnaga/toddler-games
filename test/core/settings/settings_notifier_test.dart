import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsService service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = SettingsService(prefs);
    container = ProviderContainer(
      overrides: [settingsServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
  });

  group('SettingsNotifier', () {
    test('initial state is the service default', () {
      final state = container.read(settingsProvider);
      expect(state, const SettingsState());
    });

    test('setLocale updates state and persists', () async {
      await container.read(settingsProvider.notifier).setLocale('en');
      expect(container.read(settingsProvider).locale, 'en');
      expect(service.read().locale, 'en');
    });

    test('setSoundEnabled updates state and persists', () async {
      await container
          .read(settingsProvider.notifier)
          .setSoundEnabled(enabled: false);
      expect(container.read(settingsProvider).soundEnabled, isFalse);
      expect(service.read().soundEnabled, isFalse);
    });

    test('toggleGameEnabled flips per-game enable state', () async {
      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      // zoo started enabled, so toggle removes it
      expect(
        container.read(settingsProvider).enabledGames,
        isNot(contains('zoo')),
      );

      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      expect(container.read(settingsProvider).enabledGames, contains('zoo'));
    });
  });
}
