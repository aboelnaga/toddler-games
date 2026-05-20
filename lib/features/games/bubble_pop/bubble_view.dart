import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/bubble_pop/models/bubble.dart';

/// Renders a single [Bubble] as a positioned, tappable circle with a soft
/// highlight in the upper-left quadrant for that "bubble" look.
class BubbleView extends StatelessWidget {
  const BubbleView({
    required this.bubble,
    required this.onTap,
    super.key,
  });

  final Bubble bubble;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final size = bubble.radius * 2;
    return Positioned(
      left: bubble.position.dx - bubble.radius,
      top: bubble.position.dy - bubble.radius,
      width: size,
      height: size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: CustomPaint(
          painter: _BubblePainter(color: bubble.color),
          size: Size.square(size),
        ),
      ),
    );
  }
}

class _BubblePainter extends CustomPainter {
  const _BubblePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final fill = Paint()..color = color.withValues(alpha: 0.7);
    canvas.drawCircle(center, radius, fill);

    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius - 1, ring);

    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.55);
    final highlightRect = Rect.fromCenter(
      center: Offset(center.dx - radius * 0.35, center.dy - radius * 0.35),
      width: radius * 0.55,
      height: radius * 0.4,
    );
    canvas.drawOval(highlightRect, highlight);
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) =>
      oldDelegate.color != color;
}
