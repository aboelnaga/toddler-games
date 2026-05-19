import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';

void main() {
  group('ParentGateProblem', () {
    test('addends are between 1 and 9 inclusive', () {
      final rng = Random(42);
      for (var i = 0; i < 100; i++) {
        final p = ParentGateProblem.generate(rng);
        expect(p.a, inInclusiveRange(1, 9));
        expect(p.b, inInclusiveRange(1, 9));
      }
    });

    test('correctAnswer equals a + b', () {
      final rng = Random(42);
      for (var i = 0; i < 50; i++) {
        final p = ParentGateProblem.generate(rng);
        expect(p.correctAnswer, p.a + p.b);
      }
    });

    test(
      'choices contains exactly 4 unique values including the correct one',
      () {
        final rng = Random(42);
        for (var i = 0; i < 50; i++) {
          final p = ParentGateProblem.generate(rng);
          expect(p.choices, hasLength(4));
          expect(p.choices.toSet(), hasLength(4));
          expect(p.choices, contains(p.correctAnswer));
        }
      },
    );

    test('isCorrect returns true only for the right answer', () {
      final rng = Random(42);
      final p = ParentGateProblem.generate(rng);
      expect(p.isCorrect(p.correctAnswer), isTrue);
      for (final c in p.choices.where((c) => c != p.correctAnswer)) {
        expect(p.isCorrect(c), isFalse);
      }
    });

    test('formatNumber renders Arabic-Indic numerals when locale is ar', () {
      expect(ParentGateProblem.formatNumber(7, 'ar-EG'), '٧');
      expect(ParentGateProblem.formatNumber(10, 'ar-EG'), '١٠');
    });

    test('formatNumber renders Western numerals when locale is en', () {
      expect(ParentGateProblem.formatNumber(7, 'en'), '7');
      expect(ParentGateProblem.formatNumber(10, 'en'), '10');
    });
  });
}
