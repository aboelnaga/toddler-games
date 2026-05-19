import 'package:flutter/material.dart';

// Project-wide design tokens.
// Reference: docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md §4
abstract final class DesignTokens {
  // --- Color palette (warm storybook + flat-illustrated hybrid)
  static const Color foxOrange = Color(0xFFFF8C42);
  static const Color cream = Color(0xFFFFF5E6);
  static const Color skyPeach = Color(0xFFFFE1C0);
  static const Color meadowGreen = Color(0xFFA8D895);
  static const Color blushPink = Color(0xFFFF6B9D);
  static const Color textCharcoal = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color overlayDim = Color(0x66000000);

  // --- Spacing (4dp grid)
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;
  static const double space8 = 64;

  // --- Radii
  static const double radiusS = 8;
  static const double radiusM = 16;
  static const double radiusL = 24;
  static const double radiusXL = 32;

  // --- Touch targets (toddler-friendly; larger than Apple's 44dp)
  static const double minTouchTarget = 64;
  static const double tileSize = 120;

  // --- Type sizes
  static const double fontSizeBody = 16;
  static const double fontSizeTitle = 22;
  static const double fontSizeDisplay = 36; // parent-gate math problem
}
