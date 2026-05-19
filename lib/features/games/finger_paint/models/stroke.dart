import 'package:flutter/material.dart';

/// A single drawn path.
///
/// [isMagic] causes the renderer to cycle HSV hue along the path
/// instead of using a flat [color].
class Stroke {
  const Stroke({
    required this.points,
    required this.color,
    this.strokeWidth = 14,
    this.isMagic = false,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isMagic;
}
