import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// Sparkle icon button that toggles the rainbow magic brush.
class MagicModeButton extends StatelessWidget {
  const MagicModeButton({
    required this.isActive,
    required this.onToggle,
    super.key,
  });

  final bool isActive;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: DesignTokens.minTouchTarget,
        height: DesignTokens.minTouchTarget,
        decoration: BoxDecoration(
          color: isActive
              ? DesignTokens.foxOrange.withValues(alpha: 0.9)
              : Colors.white.withValues(alpha: 0.7),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.auto_awesome,
          size: 32,
          color: DesignTokens.textCharcoal,
        ),
      ),
    );
  }
}
