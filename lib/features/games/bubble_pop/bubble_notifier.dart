import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble_pop_state.dart';

/// Drives the Bubble Pop game state: spawn cadence, per-frame motion, and
/// tap-to-pop removal.
///
/// Randomness is injected so tests can pin behaviour with a fixed seed.
class BubbleNotifier extends Notifier<BubblePopState> {
  BubbleNotifier({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _nextId = 0;

  static const double minRadius = 36;
  static const double maxRadius = 64;
  static const double minVelocity = 40;
  static const double maxVelocity = 90;
  static const double minSpawnInterval = 0.4;
  static const double maxSpawnInterval = 1.1;
  static const int maxBubbles = 24;
  static const double offScreenMargin = 20;

  static const List<Color> palette = [
    Color(0xFFE53935), // red
    Color(0xFFFB8C00), // orange
    Color(0xFFFDD835), // yellow
    Color(0xFF43A047), // green
    Color(0xFF1E88E5), // blue
    Color(0xFF8E24AA), // purple
  ];

  @override
  BubblePopState build() => const BubblePopState();

  /// Advances the simulation by [dt] seconds against the current canvas
  /// [size]. Off-screen bubbles are dropped; the spawn timer counts down
  /// and triggers a new bubble when it hits zero (subject to [maxBubbles]).
  void tick(double dt, Size size) {
    final moved = <Bubble>[];
    for (final b in state.bubbles) {
      final newY = b.position.dy - b.velocityY * dt;
      if (newY + b.radius < -offScreenMargin) continue;
      moved.add(b.copyWith(position: Offset(b.position.dx, newY)));
    }

    var remaining = state.secondsUntilNextSpawn - dt;
    var list = moved;
    if (remaining <= 0) {
      if (list.length < maxBubbles) {
        list = [...list, _spawnBubble(size)];
        remaining = _drawSpawnInterval();
      } else {
        // At cap — hold the timer at zero so we try again next tick.
        remaining = 0;
      }
    }

    state = state.copyWith(bubbles: list, secondsUntilNextSpawn: remaining);
  }

  /// Immediately spawns one bubble (used by tests and to prime the screen).
  void spawn(Size size) {
    if (state.bubbles.length >= maxBubbles) return;
    state = state.copyWith(bubbles: [...state.bubbles, _spawnBubble(size)]);
  }

  /// Removes the bubble whose id matches [id]. No-op if not found.
  void pop(int id) {
    state = state.copyWith(
      bubbles: state.bubbles.where((b) => b.id != id).toList(growable: false),
    );
  }

  /// Wipes all bubbles and resets the spawn timer.
  void reset() {
    state = const BubblePopState();
  }

  /// Test-only: replace the current bubble list outright.
  @visibleForTesting
  void debugSeed(List<Bubble> bubbles) {
    state = state.copyWith(bubbles: bubbles);
  }

  /// Test-only: force the spawn timer to a specific value.
  @visibleForTesting
  void debugSetSpawnTimer(double seconds) {
    state = state.copyWith(secondsUntilNextSpawn: seconds);
  }

  Bubble _spawnBubble(Size size) {
    final radius = minRadius + _random.nextDouble() * (maxRadius - minRadius);
    final velocity =
        minVelocity + _random.nextDouble() * (maxVelocity - minVelocity);
    final color = palette[_random.nextInt(palette.length)];
    final x = radius + _random.nextDouble() * (size.width - radius * 2);
    final y = size.height + radius;
    return Bubble(
      id: _nextId++,
      position: Offset(x, y),
      radius: radius,
      color: color,
      velocityY: velocity,
    );
  }

  double _drawSpawnInterval() {
    return minSpawnInterval +
        _random.nextDouble() * (maxSpawnInterval - minSpawnInterval);
  }
}

final bubbleProvider = NotifierProvider<BubbleNotifier, BubblePopState>(
  BubbleNotifier.new,
);
