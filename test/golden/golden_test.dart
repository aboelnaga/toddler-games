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
import 'package:toddler_games/features/games/bubble_pop/bubble_notifier.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_pop_screen.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble_pop_state.dart';
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_screen.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

import '../helpers/audio_test_helper.dart';

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
  setUpAll(registerAudioFakes);

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

  group('FingerPaintScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      final paintContainer = ProviderContainer(
        parent: container,
        overrides: [
          paintProvider.overrideWith(PaintNotifier.new),
        ],
      );
      addTearDown(paintContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const FingerPaintScreen(),
          locale: _en,
          container: paintContainer,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FingerPaintScreen),
        matchesGoldenFile('goldens/finger_paint_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      final paintContainer = ProviderContainer(
        parent: container,
        overrides: [
          paintProvider.overrideWith(PaintNotifier.new),
        ],
      );
      addTearDown(paintContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const FingerPaintScreen(),
          locale: _ar,
          container: paintContainer,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FingerPaintScreen),
        matchesGoldenFile('goldens/finger_paint_ar.png'),
      );
    });
  });

  group('BubblePopScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      final bubbleContainer = ProviderContainer(
        parent: container,
        overrides: [
          bubbleProvider.overrideWith(_FrozenBubbleNotifier.new),
        ],
      );
      addTearDown(bubbleContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const BubblePopScreen(),
          locale: _en,
          container: bubbleContainer,
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(BubblePopScreen),
        matchesGoldenFile('goldens/bubble_pop_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      final bubbleContainer = ProviderContainer(
        parent: container,
        overrides: [
          bubbleProvider.overrideWith(_FrozenBubbleNotifier.new),
        ],
      );
      addTearDown(bubbleContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const BubblePopScreen(),
          locale: _ar,
          container: bubbleContainer,
        ),
      );
      await tester.pump();

      await expectLater(
        find.byType(BubblePopScreen),
        matchesGoldenFile('goldens/bubble_pop_ar.png'),
      );
    });
  });

  group('ShapeSorterScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          const ShapeSorterScreen(),
          locale: _en,
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ShapeSorterScreen),
        matchesGoldenFile('goldens/shape_sorter_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          const ShapeSorterScreen(),
          locale: _ar,
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(ShapeSorterScreen),
        matchesGoldenFile('goldens/shape_sorter_ar.png'),
      );
    });
  });
}

/// Goldens need deterministic layout; this notifier ignores [tick] entirely
/// and returns a fixed three-bubble snapshot from [build]. The Ticker in
/// BubblePopScreen still fires but its mutations are dropped here.
class _FrozenBubbleNotifier extends BubbleNotifier {
  _FrozenBubbleNotifier();

  @override
  BubblePopState build() {
    // Positions are in logical pixels; the golden viewport renders as
    // ~390x844 (1170/3 x 2532/3).
    return const BubblePopState(
      bubbles: [
        Bubble(
          id: 1,
          position: Offset(80, 720),
          radius: 50,
          color: Color(0xFFE53935),
          velocityY: 60,
        ),
        Bubble(
          id: 2,
          position: Offset(290, 560),
          radius: 60,
          color: Color(0xFF1E88E5),
          velocityY: 70,
        ),
        Bubble(
          id: 3,
          position: Offset(180, 380),
          radius: 70,
          color: Color(0xFFFDD835),
          velocityY: 80,
        ),
        Bubble(
          id: 4,
          position: Offset(300, 220),
          radius: 45,
          color: Color(0xFF43A047),
          velocityY: 50,
        ),
      ],
      secondsUntilNextSpawn: 99,
    );
  }

  @override
  void tick(double dt, Size size) {
    // Intentionally frozen.
  }
}
