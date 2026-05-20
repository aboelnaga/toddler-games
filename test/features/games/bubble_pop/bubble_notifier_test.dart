import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_notifier.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble_pop_state.dart';

const _canvas = Size(400, 800);

ProviderContainer _seededContainer(int seed) {
  final container = ProviderContainer(
    overrides: [
      bubbleProvider.overrideWith(() => BubbleNotifier(random: Random(seed))),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('BubbleNotifier', () {
    test('initial state is empty with zero spawn timer', () {
      final container = _seededContainer(1);
      final state = container.read(bubbleProvider);
      expect(state.bubbles, isEmpty);
      expect(state.secondsUntilNextSpawn, 0);
    });

    test('spawn(size) adds one bubble inside the canvas with valid props', () {
      final container = _seededContainer(1);
      container.read(bubbleProvider.notifier).spawn(_canvas);

      final state = container.read(bubbleProvider);
      expect(state.bubbles, hasLength(1));

      final b = state.bubbles.first;
      expect(
        b.radius,
        inInclusiveRange(BubbleNotifier.minRadius, BubbleNotifier.maxRadius),
      );
      expect(
        b.velocityY,
        inInclusiveRange(
          BubbleNotifier.minVelocity,
          BubbleNotifier.maxVelocity,
        ),
      );
      expect(b.position.dx, inInclusiveRange(0, _canvas.width));
      expect(b.position.dy, greaterThan(_canvas.height));
      expect(BubbleNotifier.palette.contains(b.color), isTrue);
    });

    test('tick advances bubble y upward by velocityY * dt', () {
      final container = _seededContainer(1);
      container.read(bubbleProvider.notifier).spawn(_canvas);
      final beforeY = container.read(bubbleProvider).bubbles.first.position.dy;
      final velocity = container.read(bubbleProvider).bubbles.first.velocityY;

      container.read(bubbleProvider.notifier).tick(0.5, _canvas);

      final afterY = container.read(bubbleProvider).bubbles.first.position.dy;
      expect(afterY, closeTo(beforeY - velocity * 0.5, 1e-9));
    });

    test('tick removes bubbles that travel off the top', () {
      final container = _seededContainer(1);
      // Seed a bubble near the top; park the spawn timer so this tick
      // can't add a fresh one.
      container.read(bubbleProvider.notifier)
        ..debugSeed(const [
          Bubble(
            id: 1,
            position: Offset(100, 5),
            radius: 40,
            color: Color(0xFFE53935),
            velocityY: 100,
          ),
        ])
        ..debugSetSpawnTimer(99)
        ..tick(1, _canvas);

      expect(container.read(bubbleProvider).bubbles, isEmpty);
    });

    test('tick triggers spawn when timer hits zero', () {
      final container = _seededContainer(1);
      expect(container.read(bubbleProvider).bubbles, isEmpty);

      container.read(bubbleProvider.notifier).tick(0.016, _canvas);

      final state = container.read(bubbleProvider);
      expect(state.bubbles, hasLength(1));
      expect(
        state.secondsUntilNextSpawn,
        inInclusiveRange(
          BubbleNotifier.minSpawnInterval,
          BubbleNotifier.maxSpawnInterval,
        ),
      );
    });

    test('tick respects max-bubble cap', () {
      final container = _seededContainer(1);
      container.read(bubbleProvider.notifier)
        ..debugSeed(
          List<Bubble>.generate(
            BubbleNotifier.maxBubbles,
            (i) => Bubble(
              id: 1000 + i,
              position: const Offset(100, 400),
              radius: 40,
              color: const Color(0xFFE53935),
              velocityY: 50,
            ),
          ),
        )
        ..tick(0.016, _canvas);

      expect(
        container.read(bubbleProvider).bubbles,
        hasLength(BubbleNotifier.maxBubbles),
      );
    });

    test('pop removes the matching bubble; missing id is a no-op', () {
      final container = _seededContainer(1);
      container.read(bubbleProvider.notifier).debugSeed(const [
        Bubble(
          id: 7,
          position: Offset(50, 600),
          radius: 40,
          color: Color(0xFFE53935),
          velocityY: 60,
        ),
        Bubble(
          id: 8,
          position: Offset(150, 600),
          radius: 40,
          color: Color(0xFF1E88E5),
          velocityY: 60,
        ),
      ]);

      container.read(bubbleProvider.notifier).pop(7);
      expect(container.read(bubbleProvider).bubbles.map((b) => b.id), [8]);

      container.read(bubbleProvider.notifier).pop(999);
      expect(container.read(bubbleProvider).bubbles.map((b) => b.id), [8]);
    });

    test('reset clears bubbles and the spawn timer', () {
      final container = _seededContainer(1);
      container.read(bubbleProvider.notifier)
        ..spawn(_canvas)
        ..tick(0.016, _canvas)
        ..reset();

      final state = container.read(bubbleProvider);
      expect(state.bubbles, isEmpty);
      expect(state.secondsUntilNextSpawn, 0);
    });

    test('spawned bubbles have unique ids', () {
      final container = _seededContainer(1);
      for (var i = 0; i < 5; i++) {
        container.read(bubbleProvider.notifier).spawn(_canvas);
      }
      final ids = container
          .read(bubbleProvider)
          .bubbles
          .map((b) => b.id)
          .toSet();
      expect(ids, hasLength(5));
    });

    test('two notifiers with the same seed produce identical first bubble', () {
      final a = _seededContainer(42);
      final b = _seededContainer(42);
      a.read(bubbleProvider.notifier).spawn(_canvas);
      b.read(bubbleProvider.notifier).spawn(_canvas);

      final ba = a.read(bubbleProvider).bubbles.first;
      final bb = b.read(bubbleProvider).bubbles.first;
      expect(ba.position, bb.position);
      expect(ba.radius, bb.radius);
      expect(ba.velocityY, bb.velocityY);
      expect(ba.color, bb.color);
    });
  });

  group('BubblePopState.copyWith', () {
    test('preserves untouched fields', () {
      const original = BubblePopState(
        bubbles: [
          Bubble(
            id: 1,
            position: Offset.zero,
            radius: 40,
            color: Color(0xFFE53935),
            velocityY: 50,
          ),
        ],
        secondsUntilNextSpawn: 0.75,
      );
      final copy = original.copyWith();
      expect(copy.bubbles, original.bubbles);
      expect(copy.secondsUntilNextSpawn, original.secondsUntilNextSpawn);
    });
  });
}
