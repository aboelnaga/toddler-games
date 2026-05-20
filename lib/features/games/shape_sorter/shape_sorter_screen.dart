import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/games/shape_sorter/draggable_shape.dart';
import 'package:toddler_games/features/games/shape_sorter/models/shape_kind.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_hole.dart';
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_notifier.dart';

/// Delay before auto-starting the next round after a celebration.
const _kCelebrationDuration = Duration(milliseconds: 1400);

class ShapeSorterScreen extends ConsumerStatefulWidget {
  const ShapeSorterScreen({super.key});

  @override
  ConsumerState<ShapeSorterScreen> createState() => _ShapeSorterScreenState();
}

class _ShapeSorterScreenState extends ConsumerState<ShapeSorterScreen> {
  int? _lastCelebratedRound;
  Timer? _resetTimer;

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  void _handleAccept(ShapeKind kind) {
    final audio = ref.read(audioServiceProvider);
    ref.read(shapeSorterProvider.notifier).place(kind);
    unawaited(audio.playSfx('shape_snap'));

    final state = ref.read(shapeSorterProvider);
    if (state.isComplete && _lastCelebratedRound != state.roundId) {
      _lastCelebratedRound = state.roundId;
      final locale = ref.read(settingsProvider).locale;
      unawaited(audio.playVoice('cheer_yay', locale));
      _resetTimer?.cancel();
      _resetTimer = Timer(_kCelebrationDuration, () {
        if (!mounted) return;
        ref.read(shapeSorterProvider.notifier).nextRound();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(shapeSorterProvider);
    final remaining = kShapeOrder
        .where((k) => !state.placed.contains(k))
        .toList();

    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final k in kShapeOrder)
                      ShapeHole(
                        kind: k,
                        filled: state.placed.contains(k),
                        onAccept: _handleAccept,
                      ),
                  ],
                ),
                SizedBox(
                  height: kShapeSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (final k in kShapeOrder)
                        if (remaining.contains(k))
                          DraggableShape(
                            kind: k,
                            color: kShapeColors[k]!,
                          )
                        else
                          const SizedBox(
                            width: kShapeSize,
                            height: kShapeSize,
                          ),
                    ],
                  ),
                ),
              ],
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
            if (state.isComplete)
              const Positioned.fill(
                child: IgnorePointer(child: _CelebrationOverlay()),
              ),
          ],
        ),
      ),
    );
  }
}

class _CelebrationOverlay extends StatelessWidget {
  const _CelebrationOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.celebration_rounded,
          size: 160,
          color: DesignTokens.foxOrange,
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
