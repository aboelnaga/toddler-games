import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';

/// Wraps three [AudioPlayer] instances — one for SFX, one for voice, one for
/// looping ambience.  All play calls are fire-and-forget; errors from missing
/// asset files are swallowed silently so the app never crashes over audio.
class AudioService {
  AudioService({required this.soundEnabled})
    : _sfxPlayer = AudioPlayer(),
      _voicePlayer = AudioPlayer(),
      _ambiencePlayer = AudioPlayer();

  final bool soundEnabled;

  final AudioPlayer _sfxPlayer;
  final AudioPlayer _voicePlayer;
  final AudioPlayer _ambiencePlayer;

  /// Plays `assets/audio/sfx/$key.mp3`.
  Future<void> playSfx(String key) async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/$key.mp3'));
    } on Object {
      // Missing SFX file — silently ignore.
    }
  }

  /// Plays `assets/audio/voice/$localeId/$key.mp3`.
  Future<void> playVoice(String key, String localeId) async {
    if (!soundEnabled) return;
    try {
      await _voicePlayer.play(
        AssetSource('audio/voice/$localeId/$key.mp3'),
      );
    } on Object {
      // Missing voice file — silently ignore.
    }
  }

  /// Plays `assets/audio/ambience/$key.mp3`, optionally looping.
  Future<void> playAmbience(String key, {bool loop = true}) async {
    if (!soundEnabled) return;
    try {
      await _ambiencePlayer.setReleaseMode(
        loop ? ReleaseMode.loop : ReleaseMode.release,
      );
      await _ambiencePlayer.play(AssetSource('audio/ambience/$key.mp3'));
    } on Object {
      // Missing ambience file — silently ignore.
    }
  }

  /// Stops the ambience player.
  Future<void> stopAmbience() async {
    try {
      await _ambiencePlayer.stop();
    } on Object {
      // Ignore stop errors.
    }
  }

  /// Releases all player resources.
  Future<void> dispose() async {
    await _sfxPlayer.dispose();
    await _voicePlayer.dispose();
    await _ambiencePlayer.dispose();
  }
}

/// Provides [AudioService] scoped to the current soundEnabled setting.
final audioServiceProvider = Provider<AudioService>((ref) {
  final soundEnabled = ref.watch(
    settingsProvider.select((s) => s.soundEnabled),
  );
  final service = AudioService(soundEnabled: soundEnabled);
  ref.onDispose(service.dispose);
  return service;
});
