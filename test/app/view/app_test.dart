import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/app/app.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';

void main() {
  group('App', () {
    testWidgets('boots into HomeScreen', (tester) async {
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
      expect(find.text('Home (scaffold)'), findsOneWidget);
    });
  });
}
