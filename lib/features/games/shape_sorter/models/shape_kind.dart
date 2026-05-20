/// Kinds of shapes the child sorts. Order is the left-to-right layout
/// order used by `shape_sorter_screen.dart` for both holes (top row) and
/// draggables (bottom row), so [kShapeOrder] is the single source of truth.
enum ShapeKind { circle, star, triangle }

const List<ShapeKind> kShapeOrder = [
  ShapeKind.circle,
  ShapeKind.star,
  ShapeKind.triangle,
];
