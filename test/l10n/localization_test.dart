import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/l10n/l10n.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('renders English strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l = AppLocalizations.of(context);
              return Text(l.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Toddler Games'), findsOneWidget);
    });

    testWidgets('renders Arabic strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              final l = AppLocalizations.of(context);
              return Text(l.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ألعاب الأطفال'), findsOneWidget);
    });
  });
}
