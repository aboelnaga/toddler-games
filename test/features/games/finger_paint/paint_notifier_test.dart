import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

ProviderContainer _makeContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('PaintNotifier', () {
    test('initial state has empty strokes, empty activePoints, red color', () {
      final container = _makeContainer();
      final state = container.read(paintProvider);
      expect(state.completedStrokes, isEmpty);
      expect(state.activePoints, isEmpty);
      expect(state.activeColor, const Color(0xFFE53935));
      expect(state.magicMode, isFalse);
      expect(state.backgroundImage, isNull);
    });

    test('startStroke adds one point to activePoints', () {
      final container = _makeContainer();
      container.read(paintProvider.notifier).startStroke(const Offset(10, 20));
      final state = container.read(paintProvider);
      expect(state.activePoints, hasLength(1));
      expect(state.activePoints.first, const Offset(10, 20));
    });

    test('extendStroke appends points to activePoints', () {
      final container = _makeContainer();
      container.read(paintProvider.notifier)
        ..startStroke(Offset.zero)
        ..extendStroke(const Offset(5, 5))
        ..extendStroke(const Offset(10, 10));
      expect(container.read(paintProvider).activePoints, hasLength(3));
    });

    test(
      'endStroke moves activePoints to completedStrokes and clears active',
      () {
        final container = _makeContainer();
        container.read(paintProvider.notifier)
          ..startStroke(Offset.zero)
          ..extendStroke(const Offset(5, 5))
          ..endStroke();
        final state = container.read(paintProvider);
        expect(state.completedStrokes, hasLength(1));
        expect(state.completedStrokes.first.points, hasLength(2));
        expect(state.activePoints, isEmpty);
      },
    );

    test(
      'endStroke preserves active color and magicMode in the created Stroke',
      () {
        final container = _makeContainer();
        container.read(paintProvider.notifier)
          ..selectColor(const Color(0xFF1E88E5))
          ..toggleMagicMode()
          ..startStroke(const Offset(1, 1))
          ..endStroke();
        final stroke = container.read(paintProvider).completedStrokes.first;
        expect(stroke.color, const Color(0xFF1E88E5));
        expect(stroke.isMagic, isTrue);
      },
    );

    test('selectColor updates activeColor', () {
      final container = _makeContainer();
      container
          .read(paintProvider.notifier)
          .selectColor(const Color(0xFF43A047));
      expect(
        container.read(paintProvider).activeColor,
        const Color(0xFF43A047),
      );
    });

    test('toggleMagicMode flips magicMode', () {
      final container = _makeContainer();
      expect(container.read(paintProvider).magicMode, isFalse);
      container.read(paintProvider.notifier).toggleMagicMode();
      expect(container.read(paintProvider).magicMode, isTrue);
      container.read(paintProvider.notifier).toggleMagicMode();
      expect(container.read(paintProvider).magicMode, isFalse);
    });

    test('clearCanvas resets strokes, activePoints, and backgroundImage', () {
      final container = _makeContainer();
      container.read(paintProvider.notifier)
        ..startStroke(Offset.zero)
        ..endStroke()
        ..clearCanvas();
      final state = container.read(paintProvider);
      expect(state.completedStrokes, isEmpty);
      expect(state.activePoints, isEmpty);
      expect(state.backgroundImage, isNull);
    });

    test('needsCheckpoint is false below 50 strokes', () {
      final container = _makeContainer();
      for (var i = 0; i < 49; i++) {
        container.read(paintProvider.notifier)
          ..startStroke(Offset(i.toDouble(), 0))
          ..endStroke();
      }
      expect(container.read(paintProvider).needsCheckpoint, isFalse);
    });

    test('needsCheckpoint is true at exactly 50 strokes', () {
      final container = _makeContainer();
      for (var i = 0; i < 50; i++) {
        container.read(paintProvider.notifier)
          ..startStroke(Offset(i.toDouble(), 0))
          ..endStroke();
      }
      expect(container.read(paintProvider).needsCheckpoint, isTrue);
    });

    test(
      'applyCheckpoint stores backgroundImage and clears completedStrokes',
      () async {
        final container = _makeContainer();

        // Create a tiny valid ui.Image before touching the notifier.
        final recorder = ui.PictureRecorder();
        Canvas(recorder).drawColor(const Color(0xFFFFFFFF), BlendMode.src);
        final picture = recorder.endRecording();
        final image = await picture.toImage(1, 1);

        container.read(paintProvider.notifier)
          ..startStroke(Offset.zero)
          ..endStroke()
          ..applyCheckpoint(image);
        final state = container.read(paintProvider);
        expect(state.backgroundImage, isNotNull);
        expect(state.completedStrokes, isEmpty);
      },
    );
  });
}
