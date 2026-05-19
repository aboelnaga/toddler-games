import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = SettingsService(prefs);
  });

  group('SettingsService', () {
    test('returns defaults when nothing is persisted', () {
      final state = service.read();
      expect(state, const SettingsState());
      expect(state.locale, 'ar-EG');
      expect(state.soundEnabled, isTrue);
      expect(state.enabledGames, hasLength(5));
    });

    test('writes and reads back a modified state', () async {
      const updated = SettingsState(
        locale: 'en',
        soundEnabled: false,
        enabledGames: <String>['zoo', 'shape_sorter'],
      );
      await service.write(updated);
      final read = service.read();
      expect(read, updated);
    });

    test('persisted state survives a re-instantiation', () async {
      const updated = SettingsState(locale: 'en');
      await service.write(updated);
      final fresh = SettingsService(prefs);
      expect(fresh.read().locale, 'en');
    });

    test('falls back to defaults on corrupted JSON', () async {
      await prefs.setString('settings_v1', '{not valid json');
      final read = service.read();
      expect(read, const SettingsState());
    });
  });
}
