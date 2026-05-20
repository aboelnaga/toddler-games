import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_painter.dart';

/// Side length of a hole's drag-accepting area. Larger than `kShapeSize`
/// so the snap radius is generous — a near-miss still snaps in.
const double kHoleSize = 110;

/// Brand fill colors for placed shapes (matches the draggable counterparts).
const Map<ShapeKind, Color> kShapeColors = {
  ShapeKind.circle: Color(0xFFE53935),
  ShapeKind.star: Color(0xFFFDD835),
  ShapeKind.triangle: Color(0xFF1E88E5),
};

/// Outlined target for a single [ShapeKind].
///
/// When [filled] is true, the hole shows the filled colored shape instead of
/// an outline (and stops accepting drops).
class ShapeHole extends StatelessWidget {
  const ShapeHole({
    required this.kind,
    required this.filled,
    required this.onAccept,
    super.key,
  });

  final ShapeKind kind;
  final bool filled;
  final ValueChanged<ShapeKind> onAccept;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ShapeKind>(
      onWillAcceptWithDetails: (details) => !filled && details.data == kind,
      onAcceptWithDetails: (details) => onAccept(details.data),
      builder: (context, candidate, rejected) {
        return SizedBox(
          width: kHoleSize,
          height: kHoleSize,
          child: CustomPaint(
            painter: ShapePainter(
              kind: kind,
              color: filled
                  ? kShapeColors[kind]!
                  : Colors.black.withValues(alpha: 0.25),
              outlined: !filled,
            ),
          ),
        );
      },
    );
  }
}
