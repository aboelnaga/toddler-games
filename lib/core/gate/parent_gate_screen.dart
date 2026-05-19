import 'package:flutter/material.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/l10n/l10n.dart';

class ParentGateScreen extends StatelessWidget {
  const ParentGateScreen({
    required this.problem,
    required this.localeId,
    required this.onSuccess,
    this.onWrongAnswer,
    super.key,
  });

  final ParentGateProblem problem;
  final String localeId;
  final VoidCallback onSuccess;
  final VoidCallback? onWrongAnswer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = ParentGateProblem.formatNumber(problem.a, localeId);
    final b = ParentGateProblem.formatNumber(problem.b, localeId);

    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.settingsForGrownUps,
                  style: const TextStyle(
                    fontSize: DesignTokens.fontSizeBody,
                    color: DesignTokens.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: DesignTokens.space5),
                Text(
                  l
                      .parentGatePrompt(problem.a, problem.b)
                      .replaceAll(problem.a.toString(), a)
                      .replaceAll(problem.b.toString(), b),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: DesignTokens.space6),
                Wrap(
                  spacing: DesignTokens.space3,
                  runSpacing: DesignTokens.space3,
                  alignment: WrapAlignment.center,
                  children: problem.choices
                      .map(
                        (c) => FilledButton(
                          onPressed: () {
                            if (problem.isCorrect(c)) {
                              onSuccess();
                            } else {
                              onWrongAnswer?.call();
                            }
                          },
                          child: Text(
                            ParentGateProblem.formatNumber(c, localeId),
                            style: const TextStyle(
                              fontSize: DesignTokens.fontSizeTitle,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  l.parentGateHelp,
                  style: const TextStyle(
                    color: DesignTokens.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
