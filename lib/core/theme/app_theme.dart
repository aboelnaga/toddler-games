import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.foxOrange,
      surface: DesignTokens.cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DesignTokens.cream,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: DesignTokens.fontSizeBody,
          color: DesignTokens.textCharcoal,
        ),
        titleLarge: TextStyle(
          fontSize: DesignTokens.fontSizeTitle,
          color: DesignTokens.textCharcoal,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: TextStyle(
          fontSize: DesignTokens.fontSizeDisplay,
          color: DesignTokens.textCharcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            DesignTokens.minTouchTarget,
            DesignTokens.minTouchTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space5,
            vertical: DesignTokens.space3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        elevation: 2,
      ),
    );
  }
}
