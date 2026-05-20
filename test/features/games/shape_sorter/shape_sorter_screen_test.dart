import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/games/shape_sorter/draggable_shape.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_hole.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_notifier.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_screen.dart';
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

  group('ShapeSorterScreen', () {
    testWidgets('renders three holes and three draggables initially', (
      tester,
    ) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ShapeSorterScreen(), container: container),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ShapeHole), findsNWidgets(3));
      expect(find.byType(DraggableShape), findsNWidgets(3));
    });

    testWidgets('renders home button', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const ShapeSorterScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets(
      'placing a shape removes its draggable but keeps the hole',
      (tester) async {
        final container = await _makeContainer();
        await tester.pumpWidget(
          _wrap(const ShapeSorterScreen(), container: container),
        );
        await tester.pumpAndSettle();

        container.read(shapeSorterProvider.notifier).place(ShapeKind.circle);
        await tester.pumpAndSettle();

        expect(find.byType(DraggableShape), findsNWidgets(2));
        expect(find.byType(ShapeHole), findsNWidgets(3));
      },
    );

    testWidgets(
      'placing all three shapes shows the celebration overlay',
      (tester) async {
        final container = await _makeContainer();
        await tester.pumpWidget(
          _wrap(const ShapeSorterScreen(), container: container),
        );
        await tester.pumpAndSettle();

        container.read(shapeSorterProvider.notifier)
          ..place(ShapeKind.circle)
          ..place(ShapeKind.star)
          ..place(ShapeKind.triangle);
        await tester.pump();

        expect(find.byIcon(Icons.celebration_rounded), findsOneWidget);
      },
    );
  });
}
