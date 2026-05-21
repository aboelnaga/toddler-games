import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/features/games/zoo/models/zoo_animal.dart';

/// A single tappable zoo animal sprite.
///
/// On tap it plays a brief scale-bounce, fires the animal's vocalisation
/// SFX, and shortly after speaks the animal's name in the active locale.
/// There is no "wrong" tap — every tap is the win condition.
class AnimalView extends ConsumerStatefulWidget {
  const AnimalView({
    required this.config,
    required this.tileSize,
    super.key,
  });

  /// Per-animal asset path + audio key configuration.
  final ZooAnimalConfig config;

  /// Side length of the rendered sprite in logical pixels (already scaled
  /// by [ZooAnimalConfig.scale] by the parent).
  final double tileSize;

  @override
  ConsumerState<AnimalView> createState() => _AnimalViewState();
}

class _AnimalViewState extends ConsumerState<AnimalView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  /// Delay between the SFX (vocalisation) and the spoken name so they don't
  /// overlap.
  static const _voiceDelay = Duration(milliseconds: 250);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.15,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final audio = ref.read(audioServiceProvider);
    final locale = ref.read(settingsProvider).locale;
    unawaited(_controller.forward(from: 0));
    unawaited(audio.playSfx(widget.config.sfxKey));
    Future<void>.delayed(_voiceDelay, () {
      if (!mounted) return;
      unawaited(audio.playVoice(widget.config.voiceKey, locale));
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: ScaleTransition(
        scale: _scale,
        child: Image.asset(
          widget.config.assetPath,
          width: widget.tileSize,
          height: widget.tileSize,
        ),
      ),
    );
  }
}
