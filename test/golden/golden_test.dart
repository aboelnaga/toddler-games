// @Tags annotation applied below registers these tests so they can be run
// with `flutter test --tags golden` and skipped elsewhere.
// Golden files are platform-specific (macOS only in CI).
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/theme/app_theme.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

Widget _wrap(
  Widget child, {
  required Locale locale,
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      theme: AppTheme.light(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    ),
  );
}

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      versionProvider.overrideWith((ref) => Future.value('1.0.0')),
    ],
  );
  return container;
}

void _setPhoneViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
}

const _en = Locale('en');
const _ar = Locale('ar', 'EG');

// Fixed problem so golden output is deterministic.
final _fixedProblem = ParentGateProblem(
  a: 3,
  b: 4,
  choices: [5, 7, 8, 9],
);

void main() {
  group('HomeScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(const HomeScreen(), locale: _en, container: container),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(const HomeScreen(), locale: _ar, container: container),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('goldens/home_ar.png'),
      );
    });
  });

  group('ParentGateScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          ParentGateScreen(
            problem: _fixedProblem,
            localeId: 'en',
            onSuccess: () {},
          ),
          locale: _en,
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ParentGateScreen),
        matchesGoldenFile('goldens/parent_gate_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          ParentGateScreen(
            problem: _fixedProblem,
            localeId: 'ar-EG',
            onSuccess: () {},
          ),
          locale: _ar,
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ParentGateScreen),
        matchesGoldenFile('goldens/parent_gate_ar.png'),
      );
    });
  });

  group('SettingsScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: _en, container: container),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(const SettingsScreen(), locale: _ar, container: container),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('goldens/settings_ar.png'),
      );
    });
  });
}
