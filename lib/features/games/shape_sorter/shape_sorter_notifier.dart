import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_sorter_state.dart';

class ShapeSorterNotifier extends Notifier<ShapeSorterState> {
  @override
  ShapeSorterState build() => const ShapeSorterState();

  /// Marks [kind]'s hole as filled. Re-placing the same kind is a no-op.
  void place(ShapeKind kind) {
    if (state.placed.contains(kind)) return;
    state = state.copyWith(placed: {...state.placed, kind});
  }

  /// Starts a fresh round: empties [ShapeSorterState.placed] and bumps the
  /// round counter so animations can key off it.
  void nextRound() {
    state = ShapeSorterState(roundId: state.roundId + 1);
  }
}

final shapeSorterProvider =
    NotifierProvider<ShapeSorterNotifier, ShapeSorterState>(
      ShapeSorterNotifier.new,
    );
