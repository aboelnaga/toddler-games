import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_notifier.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_pop_screen.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_view.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

import '../../../helpers/audio_test_helper.dart';

Widget _wrap(Widget child, {required ProviderContainer container}) {
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

Future<ProviderContainer> _makeContainer({int seed = 1}) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      bubbleProvider.overrideWith(() => BubbleNotifier(random: Random(seed))),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUpAll(registerAudioFakes);

  group('BubblePopScreen', () {
    testWidgets('renders the home button', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const BubblePopScreen(), container: container),
      );
      // Pump a frame but don't settle (the Ticker never stops).
      await tester.pump();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('renders one BubbleView per seeded bubble', (tester) async {
      final container = await _makeContainer();
      container.read(bubbleProvider.notifier).debugSeed(const [
        Bubble(
          id: 1,
          position: Offset(100, 600),
          radius: 40,
          color: Color(0xFFE53935),
          velocityY: 60,
        ),
        Bubble(
          id: 2,
          position: Offset(200, 500),
          radius: 50,
          color: Color(0xFF1E88E5),
          velocityY: 70,
        ),
        Bubble(
          id: 3,
          position: Offset(300, 400),
          radius: 45,
          color: Color(0xFF43A047),
          velocityY: 80,
        ),
      ]);

      await tester.pumpWidget(
        _wrap(const BubblePopScreen(), container: container),
      );
      await tester.pump();

      expect(find.byType(BubbleView), findsNWidgets(3));
    });

    testWidgets('tapping a bubble removes it from state', (tester) async {
      final container = await _makeContainer();
      container.read(bubbleProvider.notifier).debugSeed(const [
        Bubble(
          id: 42,
          position: Offset(200, 400),
          radius: 60,
          color: Color(0xFFE53935),
          velocityY: 60,
        ),
      ]);
      // Keep the spawn timer parked so no new bubble appears mid-tap.
      container.read(bubbleProvider.notifier).debugSetSpawnTimer(99);

      await tester.pumpWidget(
        _wrap(const BubblePopScreen(), container: container),
      );
      await tester.pump();

      expect(container.read(bubbleProvider).bubbles, hasLength(1));

      await tester.tap(find.byType(BubbleView));
      await tester.pump();

      final remainingIds = container
          .read(bubbleProvider)
          .bubbles
          .map((b) => b.id)
          .toList();
      expect(remainingIds.contains(42), isFalse);
    });

    testWidgets('initial render has no bubbles before first tick', (
      tester,
    ) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const BubblePopScreen(), container: container),
      );
      await tester.pump();
      // First frame delta is zero so no spawn happens yet.
      expect(find.byType(BubbleView), findsNothing);
    });
  });
}
