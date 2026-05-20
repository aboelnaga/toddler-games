import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_painter.dart';

/// Side length of a draggable shape, in logical pixels.
const double kShapeSize = 100;

/// A draggable shape that carries its [ShapeKind] as the drag payload.
///
/// While dragging, the original is hidden (transparent placeholder) and the
/// dragged feedback shows the same shape. If the drop is rejected, Flutter's
/// [Draggable] runs a built-in spring-back animation back to origin — no
/// explicit code needed.
class DraggableShape extends StatelessWidget {
  const DraggableShape({
    required this.kind,
    required this.color,
    super.key,
  });

  final ShapeKind kind;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: kShapeSize,
      height: kShapeSize,
      child: CustomPaint(
        painter: ShapePainter(kind: kind, color: color),
      ),
    );

    return Draggable<ShapeKind>(
      data: kind,
      feedback: Material(color: Colors.transparent, child: art),
      childWhenDragging: const SizedBox(
        width: kShapeSize,
        height: kShapeSize,
      ),
      child: art,
    );
  }
}
