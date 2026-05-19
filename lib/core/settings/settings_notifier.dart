import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

/// Provider for [SettingsService]. Overridden in bootstrap with the real
/// instance backed by SharedPreferences.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Override settingsServiceProvider in bootstrap');
});

/// The current settings state. Mutations go through the notifier; widgets
/// watch this provider for reactive rebuilds.
final settingsProvider = NotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<SettingsState> {
  @override
  SettingsState build() => ref.read(settingsServiceProvider).read();

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await ref.read(settingsServiceProvider).write(state);
  }

  Future<void> setSoundEnabled({required bool enabled}) async {
    state = state.copyWith(soundEnabled: enabled);
    await ref.read(settingsServiceProvider).write(state);
  }

  Future<void> toggleGameEnabled(String gameId) async {
    final games = [...state.enabledGames];
    if (games.contains(gameId)) {
      games.remove(gameId);
    } else {
      games.add(gameId);
    }
    state = state.copyWith(enabledGames: games);
    await ref.read(settingsServiceProvider).write(state);
  }
}
