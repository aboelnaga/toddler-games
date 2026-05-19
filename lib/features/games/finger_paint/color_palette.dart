import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

const kPaletteColors = <Color>[
  Color(0xFFE53935), // red
  Color(0xFFFB8C00), // orange
  Color(0xFFFFEE58), // yellow
  Color(0xFF43A047), // green
  Color(0xFF1E88E5), // blue
  Color(0xFF8E24AA), // purple
  Color(0xFFFFFFFF), // white
  Color(0xFF212121), // black (charcoal)
];

/// Horizontal strip of 8 color-circle buttons.
class ColorPalette extends StatelessWidget {
  const ColorPalette({
    required this.selectedColor,
    required this.onColorSelected,
    super.key,
  });

  final Color selectedColor;
  final ValueChanged<Color> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: kPaletteColors.map((color) {
        final isSelected = color == selectedColor;
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space1,
          ),
          child: GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: Colors.white, width: 3)
                    : Border.all(color: Colors.black26),
                boxShadow: isSelected
                    ? [
                        const BoxShadow(
                          color: Colors.black38,
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
