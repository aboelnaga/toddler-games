import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/games/zoo/animal_view.dart';
import 'package:toddler_games/features/games/zoo/zoo_screen.dart';
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

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUpAll(registerAudioFakes);

  group('ZooScreen', () {
    testWidgets('renders home button', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ZooScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('renders the backdrop image', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ZooScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  'assets/images/games/zoo/scene_zoo.png',
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders all 7 AnimalView widgets', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ZooScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AnimalView), findsNWidgets(7));
    });

    testWidgets('tapping an animal does not throw', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ZooScreen(), container: container),
      );
      await tester.pumpAndSettle();

      // Tap the first AnimalView and let its animation play out.
      await tester.tap(find.byType(AnimalView).first, warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 350));
    });
  });
}
