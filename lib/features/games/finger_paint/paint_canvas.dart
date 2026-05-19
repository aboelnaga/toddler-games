import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/features/games/finger_paint/models/paint_state.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

class PaintCanvas extends ConsumerStatefulWidget {
  const PaintCanvas({super.key});

  @override
  ConsumerState<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends ConsumerState<PaintCanvas> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  bool _checkpointScheduled = false;

  void _scheduleCheckpoint() {
    if (_checkpointScheduled) return;
    _checkpointScheduled = true;
    unawaited(
      WidgetsBinding.instance.endOfFrame.then((_) async {
        _checkpointScheduled = false;
        if (!mounted) return;
        final boundary =
            _repaintBoundaryKey.currentContext?.findRenderObject()
                as RenderRepaintBoundary?;
        if (boundary == null) return;
        final pixelRatio = View.of(context).devicePixelRatio;
        final image = await boundary.toImage(
          pixelRatio: pixelRatio,
        );
        if (!mounted) return;
        ref.read(paintProvider.notifier).applyCheckpoint(image);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paintProvider);
    final notifier = ref.read(paintProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    if (state.needsCheckpoint) {
      _scheduleCheckpoint();
    }

    return GestureDetector(
      onPanStart: (details) {
        notifier.startStroke(details.localPosition);
        unawaited(audio.playSfx('paint_brush_start'));
      },
      onPanUpdate: (details) {
        notifier.extendStroke(details.localPosition);
      },
      onPanEnd: (_) {
        notifier.endStroke();
      },
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: CustomPaint(
          painter: _PaintCanvasPainter(state: state),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PaintCanvasPainter extends CustomPainter {
  const _PaintCanvasPainter({required this.state});

  final PaintState state;

  @override
  void paint(Canvas canvas, Size size) {
    if (state.backgroundImage != null) {
      canvas.drawImage(state.backgroundImage!, Offset.zero, Paint());
    }

    for (final stroke in state.completedStrokes) {
      _drawStroke(canvas, stroke);
    }

    if (state.activePoints.length >= 2) {
      final liveStroke = Stroke(
        points: state.activePoints,
        color: state.activeColor,
        isMagic: state.magicMode,
      );
      _drawStroke(canvas, liveStroke);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;
    final total = stroke.points.length;
    for (var i = 0; i < total - 1; i++) {
      final paint = Paint()
        ..color = stroke.isMagic
            ? HSVColor.fromAHSV(
                1,
                (i / total) * 360,
                1,
                1,
              ).toColor()
            : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaintCanvasPainter oldDelegate) => true;
}
