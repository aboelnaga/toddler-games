import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_notifier.dart';

ProviderContainer _makeContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('ShapeSorterNotifier', () {
    test('initial state: empty placed, round 0, not complete', () {
      final container = _makeContainer();
      final state = container.read(shapeSorterProvider);
      expect(state.placed, isEmpty);
      expect(state.roundId, 0);
      expect(state.isComplete, isFalse);
    });

    test('place adds the kind to placed', () {
      final container = _makeContainer();
      container.read(shapeSorterProvider.notifier).place(ShapeKind.circle);
      expect(
        container.read(shapeSorterProvider).placed,
        {ShapeKind.circle},
      );
    });

    test('placing the same kind twice is a no-op', () {
      final container = _makeContainer();
      container.read(shapeSorterProvider.notifier)
        ..place(ShapeKind.star)
        ..place(ShapeKind.star);
      expect(container.read(shapeSorterProvider).placed, {ShapeKind.star});
    });

    test('after placing all three, isComplete is true', () {
      final container = _makeContainer();
      container.read(shapeSorterProvider.notifier)
        ..place(ShapeKind.circle)
        ..place(ShapeKind.star)
        ..place(ShapeKind.triangle);
      expect(container.read(shapeSorterProvider).isComplete, isTrue);
    });

    test('nextRound clears placed and increments roundId', () {
      final container = _makeContainer();
      container.read(shapeSorterProvider.notifier)
        ..place(ShapeKind.circle)
        ..place(ShapeKind.star)
        ..nextRound();
      final state = container.read(shapeSorterProvider);
      expect(state.placed, isEmpty);
      expect(state.roundId, 1);
      expect(state.isComplete, isFalse);
    });
  });
}
