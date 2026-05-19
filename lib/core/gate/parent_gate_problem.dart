import 'dart:math';

/// A parent-gate addition problem.
///
/// Single-digit addends (1..9 inclusive). Four answer choices including
/// the correct one. Locale-aware numeral rendering.
class ParentGateProblem {
  ParentGateProblem({
    required this.a,
    required this.b,
    required this.choices,
  });

  /// Generate a fresh problem.
  ///
  /// [rng] is exposed for testability; production code passes `Random()`.
  factory ParentGateProblem.generate(Random rng) {
    final a = 1 + rng.nextInt(9); // 1..9
    final b = 1 + rng.nextInt(9);
    final correct = a + b;
    final choices = <int>{correct};
    while (choices.length < 4) {
      // distractors within +/- 5 of correct, clamped to >= 1
      final candidate = correct + rng.nextInt(11) - 5;
      if (candidate >= 1 && candidate != correct) {
        choices.add(candidate);
      }
    }
    final list = choices.toList()..shuffle(rng);
    return ParentGateProblem(a: a, b: b, choices: list);
  }

  final int a;
  final int b;
  final List<int> choices;

  int get correctAnswer => a + b;

  bool isCorrect(int choice) => choice == correctAnswer;

  /// Render an integer in the numeral set for [localeId].
  ///
  /// `ar-EG` → Arabic-Indic (٠–٩). Anything else → Western (0–9).
  static String formatNumber(int n, String localeId) {
    final western = n.toString();
    if (!localeId.startsWith('ar')) return western;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final sb = StringBuffer();
    for (final ch in western.runes) {
      final digit = ch - 0x30; // ASCII '0' = 0x30
      if (digit >= 0 && digit <= 9) {
        sb.write(arabicDigits[digit]);
      } else {
        sb.writeCharCode(ch);
      }
    }
    return sb.toString();
  }
}
