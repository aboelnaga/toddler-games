import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

Widget wrap(Widget child, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [
          GoRoute(path: '/', builder: (_, _) => child),
          GoRoute(path: '/home', builder: (_, _) => const SizedBox()),
        ],
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
        versionProvider.overrideWith((ref) => Future.value('1.0.0')),
      ],
    );
    addTearDown(container.dispose);
  });

  group('SettingsScreen', () {
    testWidgets('renders language section with both options', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Egyptian Arabic'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('renders sound section', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('Sound'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('renders games section with 5 game toggles', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('Games', skipOffstage: false), findsOneWidget);
      expect(find.text('Zoo', skipOffstage: false), findsOneWidget);
      expect(find.text('Bubble Pop', skipOffstage: false), findsOneWidget);
      expect(find.text('Shape Sorter', skipOffstage: false), findsOneWidget);
      expect(find.text('Finger Paint', skipOffstage: false), findsOneWidget);
      expect(find.text('Drive', skipOffstage: false), findsOneWidget);
    });

    testWidgets('renders about section with version', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.text('About', skipOffstage: false), findsOneWidget);
      expect(find.text('Version 1.0.0', skipOffstage: false), findsOneWidget);
    });

    testWidgets('tapping sound switch toggles soundEnabled', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      // Sound is enabled by default (first SwitchListTile)
      final soundSwitch = find.byType(SwitchListTile).at(0);
      await tester.tap(soundSwitch);
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).soundEnabled, isFalse);
    });

    testWidgets('tapping game switch toggles game enabled', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      // Zoo is the first game SwitchListTile (index 1 overall)
      final zooSwitch = find.byType(SwitchListTile).at(1);
      await tester.tap(zooSwitch);
      await tester.pumpAndSettle();
      expect(
        container.read(settingsProvider).enabledGames.contains('zoo'),
        isFalse,
      );
    });

    testWidgets('tapping English radio changes locale', (tester) async {
      await tester.pumpWidget(
        wrap(const SettingsScreen(), container: container),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();
      expect(container.read(settingsProvider).locale, equals('en'));
    });
  });
}
