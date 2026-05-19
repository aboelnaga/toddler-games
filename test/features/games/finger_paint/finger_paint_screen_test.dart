import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/games/finger_paint/color_palette.dart';
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
import 'package:toddler_games/features/games/finger_paint/magic_mode_button.dart';
import 'package:toddler_games/features/games/finger_paint/paint_canvas.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

Widget _wrap(
  Widget child, {
  required ProviderContainer container,
}) {
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
  group('FingerPaintScreen', () {
    testWidgets('renders PaintCanvas', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PaintCanvas), findsOneWidget);
    });

    testWidgets('renders ColorPalette', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ColorPalette), findsOneWidget);
    });

    testWidgets('renders home button with home icon', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('renders MagicModeButton', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MagicModeButton), findsOneWidget);
    });

    testWidgets('renders ClearButton (delete icon)', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping a color circle updates activeColor in PaintNotifier', (
      tester,
    ) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();

      // The orange circle is index 1 in kPaletteColors (0xFFFB8C00).
      final orangeCircle = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color == const Color(0xFFFB8C00),
      );
      await tester.tap(orangeCircle.first);
      await tester.pump();

      expect(
        container.read(paintProvider).activeColor,
        const Color(0xFFFB8C00),
      );
    });

    testWidgets('tapping MagicModeButton toggles magicMode', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();

      expect(container.read(paintProvider).magicMode, isFalse);
      await tester.tap(find.byType(MagicModeButton));
      await tester.pump();
      expect(container.read(paintProvider).magicMode, isTrue);
    });
  });
}
