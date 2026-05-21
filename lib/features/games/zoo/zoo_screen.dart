import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/games/zoo/animal_view.dart';
import 'package:toddler_games/features/games/zoo/models/zoo_animal.dart';

const String _kBackdropAsset = 'assets/images/games/zoo/scene_zoo.png';

/// Intrinsic aspect ratio of the bundled `scene_zoo.png` (3584 / 1184 ≈ 3.03).
const double _kBackdropAspect = 3584 / 1184;

/// Tile size as a fraction of the rendered backdrop height. ~22% gives each
/// animal a ~140-160 dp footprint on a typical phone — comfortably tappable
/// for a toddler.
const double _kBaseTileFraction = 0.22;

class ZooScreen extends ConsumerWidget {
  const ZooScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final sceneHeight = constraints.maxHeight;
                final sceneWidth = sceneHeight * _kBackdropAspect;
                final baseTile = sceneHeight * _kBaseTileFraction;

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: sceneWidth,
                    height: sceneHeight,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            _kBackdropAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                        for (final entry in zooAnimalConfigs.entries)
                          _PositionedAnimal(
                            key: ValueKey(entry.key),
                            config: entry.value,
                            sceneWidth: sceneWidth,
                            sceneHeight: sceneHeight,
                            baseTile: baseTile,
                          ),
                      ],
                    ),
                  ),
                );
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
        ),
      ),
    );
  }
}

class _PositionedAnimal extends StatelessWidget {
  const _PositionedAnimal({
    required this.config,
    required this.sceneWidth,
    required this.sceneHeight,
    required this.baseTile,
    super.key,
  });

  final ZooAnimalConfig config;
  final double sceneWidth;
  final double sceneHeight;
  final double baseTile;

  @override
  Widget build(BuildContext context) {
    final tile = baseTile * config.scale;
    return Positioned(
      left: config.positionX * sceneWidth - tile / 2,
      top: config.positionY * sceneHeight - tile / 2,
      child: AnimalView(config: config, tileSize: tile),
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
