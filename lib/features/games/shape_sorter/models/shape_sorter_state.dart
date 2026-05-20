import 'package:flutter/foundation.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';

/// Immutable state for the Shape Sorter game.
///
/// [placed] holds the kinds whose holes have been filled this round.
/// [roundId] increments on every `nextRound()` call so the UI can key
/// celebration animations.
@immutable
class ShapeSorterState {
  const ShapeSorterState({this.placed = const {}, this.roundId = 0});

  final Set<ShapeKind> placed;
  final int roundId;

  bool get isComplete => placed.length == ShapeKind.values.length;

  ShapeSorterState copyWith({Set<ShapeKind>? placed, int? roundId}) {
    return ShapeSorterState(
      placed: placed ?? this.placed,
      roundId: roundId ?? this.roundId,
    );
  }
}
