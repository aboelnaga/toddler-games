import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

void main() {
  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: ProviderScope(child: child),
    );
  }

  group('ParentGateScreen', () {
    testWidgets('renders the problem text + 4 choice buttons', (tester) async {
      final problem = ParentGateProblem(
        a: 7,
        b: 3,
        choices: [8, 10, 12, 15],
      );

      var success = false;
      await tester.pumpWidget(
        wrap(
          ParentGateScreen(
            problem: problem,
            localeId: 'en',
            onSuccess: () => success = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('What is 7 + 3 = ?'), findsOneWidget);
      expect(find.byType(FilledButton), findsNWidgets(4));
      expect(success, isFalse);
    });

    testWidgets('calls onSuccess when correct choice tapped', (tester) async {
      final problem = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
      var success = false;
      await tester.pumpWidget(
        wrap(
          ParentGateScreen(
            problem: problem,
            localeId: 'en',
            onSuccess: () => success = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      expect(success, isTrue);
    });

    testWidgets(
      'does NOT call onSuccess when wrong choice tapped — fires onWrongAnswer',
      (tester) async {
        var generated = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
        var success = false;
        late StateSetter setter;
        await tester.pumpWidget(
          wrap(
            StatefulBuilder(
              builder: (context, set) {
                setter = set;
                return ParentGateScreen(
                  problem: generated,
                  localeId: 'en',
                  onSuccess: () => success = true,
                  onWrongAnswer: () {
                    setter(() {
                      generated = ParentGateProblem(
                        a: 4,
                        b: 2,
                        choices: [3, 6, 8, 9],
                      );
                    });
                  },
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('8'));
        await tester.pumpAndSettle();

        expect(success, isFalse);
        expect(find.text('What is 4 + 2 = ?'), findsOneWidget);
      },
    );

    testWidgets('renders Arabic-Indic numerals when locale is ar', (
      tester,
    ) async {
      final problem = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
      await tester.pumpWidget(
        wrap(
          ParentGateScreen(
            problem: problem,
            localeId: 'ar-EG',
            onSuccess: () {},
          ),
          locale: const Locale('ar', 'EG'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('٧ + ٣ = ؟'), findsOneWidget);
      expect(find.text('١٠'), findsOneWidget);
    });
  });
}
