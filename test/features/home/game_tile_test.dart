import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/home/game_catalog.dart';
import 'package:toddler_games/features/home/game_tile.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

Widget wrap(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);

void main() {
  final zoo = GameCatalog.all.first;

  group('GameTile', () {
    testWidgets('renders emoji + title when enabled', (tester) async {
      await tester.pumpWidget(
        wrap(GameTile(entry: zoo, enabled: true, onTap: () {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('🦊'), findsOneWidget);
      expect(find.text('Zoo'), findsOneWidget);
    });

    testWidgets('shows lock icon and ignores tap when disabled', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          GameTile(entry: zoo, enabled: false, onTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsOneWidget);
      await tester.tap(find.byType(GameTile));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('invokes onTap when enabled and tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        wrap(
          GameTile(entry: zoo, enabled: true, onTap: () => tapped = true),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GameTile));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
