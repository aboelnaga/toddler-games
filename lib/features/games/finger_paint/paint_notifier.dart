import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/features/games/finger_paint/models/paint_state.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';

class PaintNotifier extends Notifier<PaintState> {
  @override
  PaintState build() => const PaintState();

  void startStroke(Offset point) {
    state = state.copyWith(activePoints: [point]);
  }

  void extendStroke(Offset point) {
    state = state.copyWith(
      activePoints: [...state.activePoints, point],
    );
  }

  void endStroke() {
    if (state.activePoints.isEmpty) return;
    final newStroke = Stroke(
      points: List.unmodifiable(state.activePoints),
      color: state.activeColor,
      isMagic: state.magicMode,
    );
    state = state.copyWith(
      completedStrokes: [...state.completedStrokes, newStroke],
      activePoints: [],
    );
  }

  void selectColor(Color color) {
    state = state.copyWith(activeColor: color);
  }

  void toggleMagicMode() {
    state = state.copyWith(magicMode: !state.magicMode);
  }

  void applyCheckpoint(ui.Image image) {
    state = state.copyWith(
      backgroundImage: image,
      completedStrokes: [],
    );
  }

  void clearCanvas() {
    state = const PaintState();
  }
}

final paintProvider = NotifierProvider<PaintNotifier, PaintState>(
  PaintNotifier.new,
);
