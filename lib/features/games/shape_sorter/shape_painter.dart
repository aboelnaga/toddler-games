import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';

/// Draws a single [ShapeKind] in [color] within the given bounds.
/// When [outlined] is true, paints as a stroked outline (used for the
/// empty holes); otherwise paints filled (used for draggable shapes).
class ShapePainter extends CustomPainter {
  const ShapePainter({
    required this.kind,
    required this.color,
    this.outlined = false,
    this.strokeWidth = 4,
  });

  final ShapeKind kind;
  final Color color;
  final bool outlined;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = outlined ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.round;

    switch (kind) {
      case ShapeKind.circle:
        final center = Offset(size.width / 2, size.height / 2);
        final radius = math.min(size.width, size.height) / 2 - strokeWidth;
        canvas.drawCircle(center, radius, paint);
      case ShapeKind.star:
        canvas.drawPath(_starPath(size), paint);
      case ShapeKind.triangle:
        canvas.drawPath(_trianglePath(size), paint);
    }
  }

  Path _trianglePath(Size size) {
    final inset = strokeWidth;
    final path = Path()
      ..moveTo(size.width / 2, inset)
      ..lineTo(size.width - inset, size.height - inset)
      ..lineTo(inset, size.height - inset)
      ..close();
    return path;
  }

  Path _starPath(Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outer = math.min(size.width, size.height) / 2 - strokeWidth;
    final inner = outer * 0.45;
    const points = 5;
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final r = i.isEven ? outer : inner;
      final angle = -math.pi / 2 + i * math.pi / points;
      final dx = center.dx + r * math.cos(angle);
      final dy = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant ShapePainter old) =>
      old.kind != kind ||
      old.color != color ||
      old.outlined != outlined ||
      old.strokeWidth != strokeWidth;
}
