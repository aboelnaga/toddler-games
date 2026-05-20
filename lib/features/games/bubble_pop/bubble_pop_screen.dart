import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_notifier.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_view.dart';

class BubblePopScreen extends ConsumerStatefulWidget {
  const BubblePopScreen({super.key});

  @override
  ConsumerState<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends ConsumerState<BubblePopScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _lastElapsed = Duration.zero;
  Size _canvasSize = Size.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
    unawaited(_ticker.start());
  }

  void _onTick(Duration elapsed) {
    final dt = _lastElapsed == Duration.zero
        ? 0.0
        : (elapsed - _lastElapsed).inMicroseconds / 1e6;
    _lastElapsed = elapsed;
    if (dt == 0 || _canvasSize == Size.zero) return;
    ref.read(bubbleProvider.notifier).tick(dt, _canvasSize);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbles = ref.watch(bubbleProvider.select((s) => s.bubbles));
    final audio = ref.read(audioServiceProvider);
    final notifier = ref.read(bubbleProvider.notifier);

    return Scaffold(
      backgroundColor: DesignTokens.skyPeach,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            _canvasSize = constraints.biggest;
            return Stack(
              children: [
                for (final b in bubbles)
                  BubbleView(
                    key: ValueKey(b.id),
                    bubble: b,
                    onTap: () {
                      notifier.pop(b.id);
                      unawaited(audio.playSfx('bubble_pop'));
                    },
                  ),
                Positioned(
                  top: DesignTokens.space2,
                  left: DesignTokens.space2,
                  child: _CircleOverlayButton(
                    onTap: () => context.go('/'),
                    child: const Icon(
                      Icons.home_rounded,
                      size: 32,
                      color: DesignTokens.textCharcoal,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CircleOverlayButton extends StatelessWidget {
  const _CircleOverlayButton({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: DesignTokens.minTouchTarget,
        height: DesignTokens.minTouchTarget,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(child: child),
      ),
    );
  }
}
