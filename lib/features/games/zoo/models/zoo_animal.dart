import 'package:flutter/foundation.dart';

/// One of the tappable animals in the Tap-to-Discover Zoo.
///
/// Declaration order is the natural left-to-right layout order on the wide
/// panoramic scene (duck beside the pond on the far left, elephant at the
/// far right).
enum ZooAnimal { duck, cow, sheep, bird, cat, dog, elephant }

/// Static per-animal config — bundled asset path, scene-space position
/// (fractions of the backdrop's intrinsic size), on-screen scale relative
/// to a tile baseline, and the audio keys for the bounce SFX and the
/// spoken name.
@immutable
class ZooAnimalConfig {
  const ZooAnimalConfig({
    required this.assetPath,
    required this.positionX,
    required this.positionY,
    required this.scale,
    required this.sfxKey,
    required this.voiceKey,
  });

  /// Bundled asset path. Must be a registered asset under `pubspec.yaml`'s
  /// `flutter.assets`.
  final String assetPath;

  /// Horizontal position as a fraction (0 – 1) of the backdrop's intrinsic
  /// width. Calibrated against the painted features in `scene_zoo.png`.
  final double positionX;

  /// Vertical position as a fraction (0 – 1) of the backdrop's intrinsic
  /// height.
  final double positionY;

  /// Multiplier applied to the baseline tile size when rendering this
  /// animal. Used to suggest depth (smaller animals further away, larger
  /// animals closer to the foreground) while staying tappable.
  final double scale;

  /// Locale-agnostic SFX key under `assets/audio/sfx/`. Plays the animal's
  /// vocalisation (moo, woof, quack, etc.).
  final String sfxKey;

  /// Locale-namespaced voice key under `assets/audio/voice/{locale}/`.
  /// Plays the spoken name of the animal in the active locale.
  final String voiceKey;
}

const Map<ZooAnimal, ZooAnimalConfig> zooAnimalConfigs = {
  ZooAnimal.duck: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_duck.png',
    positionX: 0.16,
    positionY: 0.78,
    scale: 0.85,
    sfxKey: 'animal_duck_sound',
    voiceKey: 'animal_duck',
  ),
  ZooAnimal.cow: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_cow.png',
    positionX: 0.32,
    positionY: 0.72,
    scale: 1,
    sfxKey: 'animal_cow_sound',
    voiceKey: 'animal_cow',
  ),
  ZooAnimal.sheep: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_sheep.png',
    positionX: 0.45,
    positionY: 0.70,
    scale: 0.95,
    sfxKey: 'animal_sheep_sound',
    voiceKey: 'animal_sheep',
  ),
  ZooAnimal.bird: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_bird.png',
    positionX: 0.55,
    positionY: 0.55,
    scale: 0.75,
    sfxKey: 'animal_bird_sound',
    voiceKey: 'animal_bird',
  ),
  ZooAnimal.cat: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_cat.png',
    positionX: 0.66,
    positionY: 0.74,
    scale: 0.90,
    sfxKey: 'animal_cat_sound',
    voiceKey: 'animal_cat',
  ),
  ZooAnimal.dog: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_dog.png',
    positionX: 0.78,
    positionY: 0.72,
    scale: 0.95,
    sfxKey: 'animal_dog_sound',
    voiceKey: 'animal_dog',
  ),
  ZooAnimal.elephant: ZooAnimalConfig(
    assetPath: 'assets/images/games/zoo/animal_elephant.png',
    positionX: 0.90,
    positionY: 0.68,
    scale: 1.15,
    sfxKey: 'animal_elephant_sound',
    voiceKey: 'animal_elephant',
  ),
};
