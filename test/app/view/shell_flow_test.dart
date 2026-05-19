import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/routing/router.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/home/game_tile.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        versionProvider.overrideWith((ref) => Future.value('1.0.0')),
      ],
    );
    addTearDown(container.dispose);
  });

  testWidgets(
    'shell flow: home → settings → disable game → back home shows lock',
    (tester) async {
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Home: 5 tiles, none locked
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(GameTile), findsNWidgets(5));
      expect(find.byIcon(Icons.lock), findsNothing);

      // Navigate to settings (bypassing parent gate)
      router.go('/settings');
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Toggle Zoo off (index 0 = sound, index 1 = zoo)
      final zooSwitch = find.byType(SwitchListTile).at(1);
      await tester.tap(zooSwitch);
      await tester.pumpAndSettle();
      expect(
        container.read(settingsProvider).enabledGames.contains('zoo'),
        isFalse,
      );

      // Navigate back to home
      router.go('/');
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);

      // Zoo tile now shows lock icon
      expect(find.byIcon(Icons.lock), findsOneWidget);
    },
  );
}
