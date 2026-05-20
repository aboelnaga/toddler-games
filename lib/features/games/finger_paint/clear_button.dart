import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// Trash-can button that clears the canvas after a 2-second hold.
///
/// Uses Listener (raw pointer events) instead of GestureDetector long-press
/// so the progress ring starts immediately on pointer-down, giving instant
/// visual feedback. GestureDetector long-press has a 500 ms dead zone with
/// no feedback, which caused users to release thinking nothing was happening.
class ClearButton extends StatefulWidget {
  const ClearButton({required this.onClear, super.key});

  final VoidCallback onClear;

  @override
  State<ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<ClearButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(seconds: 2),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            widget.onClear();
            _controller.reset();
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) => _controller.forward();

  void _onPointerUp(PointerUpEvent _) => _controller.reset();

  void _onPointerCancel(PointerCancelEvent _) => _controller.reset();

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: SizedBox(
        width: DesignTokens.minTouchTarget,
        height: DesignTokens.minTouchTarget,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value > 0)
                  CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 4,
                    color: Colors.redAccent,
                  ),
                child!,
              ],
            );
          },
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 32,
            color: DesignTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}
