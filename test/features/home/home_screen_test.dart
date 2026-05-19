import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/home/game_tile.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

Widget wrap(Widget child, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    ),
  );
}

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

  group('HomeScreen', () {
    testWidgets('renders 5 GameTiles', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), container: container));
      await tester.pumpAndSettle();
      expect(find.byType(GameTile), findsNWidgets(5));
    });

    testWidgets('renders the gear icon (parent-gate entry)', (tester) async {
      await tester.pumpWidget(wrap(const HomeScreen(), container: container));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('disabled game tile dims and shows lock', (tester) async {
      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      await tester.pumpWidget(wrap(const HomeScreen(), container: container));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
