import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/games/zoo/models/zoo_animal.dart';

void main() {
  group('ZooAnimal', () {
    test('exactly seven animals', () {
      expect(ZooAnimal.values, hasLength(7));
    });

    test('every animal has a config entry', () {
      for (final animal in ZooAnimal.values) {
        expect(
          zooAnimalConfigs.containsKey(animal),
          isTrue,
          reason: 'missing config for $animal',
        );
      }
    });

    test('positions are inside the (0, 1) fraction range', () {
      for (final entry in zooAnimalConfigs.entries) {
        final c = entry.value;
        expect(
          c.positionX,
          inExclusiveRange(0, 1),
          reason: '${entry.key} positionX out of range',
        );
        expect(
          c.positionY,
          inExclusiveRange(0, 1),
          reason: '${entry.key} positionY out of range',
        );
      }
    });

    test('scales are within sensible bounds', () {
      for (final entry in zooAnimalConfigs.entries) {
        expect(
          entry.value.scale,
          inInclusiveRange(0.5, 1.5),
          reason: '${entry.key} scale out of range',
        );
      }
    });

    test('asset paths point at the bundled zoo folder', () {
      for (final entry in zooAnimalConfigs.entries) {
        expect(
          entry.value.assetPath,
          startsWith('assets/images/games/zoo/animal_'),
          reason: '${entry.key} assetPath shape wrong',
        );
        expect(entry.value.assetPath.endsWith('.png'), isTrue);
      }
    });

    test('audio keys follow the animal_<name>(_sound)? convention', () {
      for (final entry in zooAnimalConfigs.entries) {
        final c = entry.value;
        expect(c.voiceKey, startsWith('animal_'));
        expect(c.sfxKey, startsWith('animal_'));
        expect(c.sfxKey, endsWith('_sound'));
      }
    });

    test('positions are unique per animal', () {
      final seen = <(double, double)>{};
      for (final entry in zooAnimalConfigs.entries) {
        final p = (entry.value.positionX, entry.value.positionY);
        expect(
          seen.add(p),
          isTrue,
          reason: 'duplicate position for ${entry.key}',
        );
      }
    });
  });
}
