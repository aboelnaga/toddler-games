import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/app/app.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/home/game_tile.dart';

void main() {
  group('App', () {
    testWidgets('boots into HomeScreen showing 5 game tiles', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GameTile), findsNWidgets(5));
    });
  });
}
