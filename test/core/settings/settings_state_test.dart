import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  group('SettingsState', () {
    test('defaults to Egyptian Arabic, sound on, all games enabled', () {
      const state = SettingsState();
      expect(state.locale, 'ar-EG');
      expect(state.soundEnabled, isTrue);
      expect(state.enabledGames, hasLength(5));
      expect(state.enabledGames, contains('zoo'));
    });

    test('round-trips through JSON', () {
      const state = SettingsState(locale: 'en', soundEnabled: false);
      final json = state.toJson();
      final decoded = SettingsState.fromJson(json);
      expect(decoded, state);
    });
  });
}
