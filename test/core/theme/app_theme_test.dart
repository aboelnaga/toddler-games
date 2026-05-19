import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/theme/app_theme.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

void main() {
  group('AppTheme.light', () {
    test('uses fox-orange as seed and produces a Material 3 theme', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, DesignTokens.cream);
      expect(theme.brightness, Brightness.light);
    });

    test('filled-button minimum size meets toddler touch target', () {
      final theme = AppTheme.light();
      final style = theme.filledButtonTheme.style!;
      final minSize = style.minimumSize?.resolve(<WidgetState>{});
      expect(minSize?.width, DesignTokens.minTouchTarget);
      expect(minSize?.height, DesignTokens.minTouchTarget);
    });
  });
}
