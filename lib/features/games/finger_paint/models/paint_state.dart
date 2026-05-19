import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';

/// Immutable state for the finger paint game.
class PaintState {
  const PaintState({
    this.completedStrokes = const [],
    this.activePoints = const [],
    this.activeColor = const Color(0xFFE53935),
    this.magicMode = false,
    this.backgroundImage,
  });

  final List<Stroke> completedStrokes;
  final List<Offset> activePoints;
  final Color activeColor;
  final bool magicMode;
  final ui.Image? backgroundImage;

  bool get needsCheckpoint => completedStrokes.length >= 50;

  PaintState copyWith({
    List<Stroke>? completedStrokes,
    List<Offset>? activePoints,
    Color? activeColor,
    bool? magicMode,
    ui.Image? backgroundImage,
    bool clearBackgroundImage = false,
  }) {
    return PaintState(
      completedStrokes: completedStrokes ?? this.completedStrokes,
      activePoints: activePoints ?? this.activePoints,
      activeColor: activeColor ?? this.activeColor,
      magicMode: magicMode ?? this.magicMode,
      backgroundImage: clearBackgroundImage
          ? null
          : (backgroundImage ?? this.backgroundImage),
    );
  }
}
