import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

/// Synchronous read / async write wrapper around SharedPreferences for the
/// app's settings.
///
/// The entire SettingsState is stored as a single JSON string under a versioned
/// key so future schema migrations are explicit (settings_v1 → settings_v2).
class SettingsService {
  SettingsService(this._prefs);

  static const _key = 'settings_v1';
  final SharedPreferences _prefs;

  SettingsState read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const SettingsState();
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return SettingsState.fromJson(json);
    } on Object catch (e, st) {
      developer.log(
        'Settings JSON corrupted; falling back to defaults',
        error: e,
        stackTrace: st,
      );
      return const SettingsState();
    }
  }

  Future<void> write(SettingsState state) async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }
}
