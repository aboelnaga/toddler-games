import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/games/finger_paint/clear_button.dart';
import 'package:toddler_games/features/games/finger_paint/color_palette.dart';
import 'package:toddler_games/features/games/finger_paint/magic_mode_button.dart';
import 'package:toddler_games/features/games/finger_paint/paint_canvas.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

class FingerPaintScreen extends ConsumerWidget {
  const FingerPaintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(paintProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final selectedColor = ref.watch(
      paintProvider.select((s) => s.activeColor),
    );
    final magicMode = ref.watch(
      paintProvider.select((s) => s.magicMode),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(child: PaintCanvas()),

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

            Positioned(
              top: DesignTokens.space2,
              right: DesignTokens.space2,
              child: MagicModeButton(
                isActive: magicMode,
                onToggle: () {
                  notifier.toggleMagicMode();
                  unawaited(audio.playSfx('paint_magic_on'));
                },
              ),
            ),

            Positioned(
              bottom: DesignTokens.space3,
              left: 0,
              right: 0,
              child: Center(
                child: _PaletteCard(
                  child: ColorPalette(
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      notifier.selectColor(color);
                      unawaited(audio.playSfx('paint_select_color'));
                    },
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: DesignTokens.space3,
              right: DesignTokens.space3,
              child: ClearButton(
                onClear: () {
                  notifier.clearCanvas();
                  unawaited(audio.playSfx('paint_canvas_clear'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleOverlayButton extends StatelessWidget {
  const _CircleOverlayButton({
    required this.onTap,
    required this.child,
  });

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

class _PaletteCard extends StatelessWidget {
  const _PaletteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space3,
        vertical: DesignTokens.space2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
