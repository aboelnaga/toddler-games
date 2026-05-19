import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// Trash-can button that clears the canvas after 2-second hold.
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reset(),
      onLongPressCancel: () => _controller.reset(),
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
