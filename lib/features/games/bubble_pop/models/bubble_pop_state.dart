import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';

/// Immutable state for the Bubble Pop game.
///
/// [bubbles] are currently on screen.
/// [secondsUntilNextSpawn] counts down each `BubbleNotifier.tick`; when it
/// drops to or below zero a new bubble is spawned (subject to the cap).
class BubblePopState {
  const BubblePopState({
    this.bubbles = const [],
    this.secondsUntilNextSpawn = 0,
  });

  final List<Bubble> bubbles;
  final double secondsUntilNextSpawn;

  BubblePopState copyWith({
    List<Bubble>? bubbles,
    double? secondsUntilNextSpawn,
  }) {
    return BubblePopState(
      bubbles: bubbles ?? this.bubbles,
      secondsUntilNextSpawn:
          secondsUntilNextSpawn ?? this.secondsUntilNextSpawn,
    );
  }
}
