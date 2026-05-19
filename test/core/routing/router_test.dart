import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/routing/router.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/home/game_tile.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('router', () {
    testWidgets('navigates / to HomeScreen', (tester) async {
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GameTile), findsNWidgets(5));
    });

    testWidgets('navigates to /settings', (tester) async {
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings (scaffold)'), findsOneWidget);
    });
  });
}
