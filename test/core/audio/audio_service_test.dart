import 'dart:async';

import 'package:audioplayers_platform_interface/audioplayers_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/audio/audio_service.dart';

// ---------------------------------------------------------------------------
// Minimal platform fakes so AudioPlayer can be instantiated in unit tests
// without a native host.  Based on the audioplayers package's own test helpers.
// ---------------------------------------------------------------------------

class _FakeGlobalPlatform extends GlobalAudioplayersPlatformInterface {
  final StreamController<GlobalAudioEvent> _ctrl =
      StreamController<GlobalAudioEvent>.broadcast();

  @override
  Future<void> init() async {}

  @override
  Future<void> setGlobalAudioContext(AudioContext ctx) async {}

  @override
  Future<void> emitGlobalLog(String message) async {}

  @override
  Future<void> emitGlobalError(String code, String message) async {
    _ctrl.addError(PlatformException(code: code, message: message));
  }

  @override
  Stream<GlobalAudioEvent> getGlobalEventStream() => _ctrl.stream;
}

class _FakePlayerPlatform extends AudioplayersPlatformInterface {
  final Map<String, StreamController<AudioEvent>> _streams = {};

  @override
  Future<void> create(String playerId) async {
    _streams[playerId] = StreamController<AudioEvent>.broadcast();
  }

  @override
  Future<void> dispose(String playerId) async {
    await _streams[playerId]?.close();
    _streams.remove(playerId);
  }

  @override
  Future<void> emitError(
    String playerId,
    String code,
    String message,
  ) async {}

  @override
  Future<void> emitLog(String playerId, String message) async {}

  @override
  Future<int?> getCurrentPosition(String playerId) async => 0;

  @override
  Future<int?> getDuration(String playerId) async => 0;

  @override
  Future<void> pause(String playerId) async {}

  @override
  Future<void> release(String playerId) async {}

  @override
  Future<void> resume(String playerId) async {}

  @override
  Future<void> seek(String playerId, Duration position) async {}

  @override
  Future<void> setAudioContext(
    String playerId,
    AudioContext audioContext,
  ) async {}

  @override
  Future<void> setBalance(String playerId, double balance) async {}

  @override
  Future<void> setPlaybackRate(
    String playerId,
    double playbackRate,
  ) async {}

  @override
  Future<void> setPlayerMode(
    String playerId,
    PlayerMode playerMode,
  ) async {}

  @override
  Future<void> setReleaseMode(
    String playerId,
    ReleaseMode releaseMode,
  ) async {}

  @override
  Future<void> setSourceBytes(
    String playerId,
    Uint8List bytes, {
    String? mimeType,
  }) async {
    _streams[playerId]?.add(
      const AudioEvent(
        eventType: AudioEventType.prepared,
        isPrepared: true,
      ),
    );
  }

  @override
  Future<void> setSourceUrl(
    String playerId,
    String url, {
    bool? isLocal,
    String? mimeType,
  }) async {
    _streams[playerId]?.add(
      const AudioEvent(
        eventType: AudioEventType.prepared,
        isPrepared: true,
      ),
    );
  }

  @override
  Future<void> setVolume(String playerId, double volume) async {}

  @override
  Future<void> stop(String playerId) async {}

  @override
  Stream<AudioEvent> getEventStream(String playerId) {
    _streams[playerId] ??= StreamController<AudioEvent>.broadcast();
    return _streams[playerId]!.stream;
  }
}

// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    GlobalAudioplayersPlatformInterface.instance = _FakeGlobalPlatform();
    AudioplayersPlatformInterface.instance = _FakePlayerPlatform();
  });

  group('AudioService', () {
    test(
      'playSfx completes without throwing when soundEnabled is false',
      () async {
        final service = AudioService(soundEnabled: false);
        await expectLater(
          service.playSfx('paint_brush_start'),
          completes,
        );
        await service.dispose();
      },
    );

    test(
      'playSfx completes without throwing when asset file does not exist',
      () async {
        final service = AudioService(soundEnabled: true);
        await expectLater(
          service.playSfx('nonexistent_file_that_does_not_exist'),
          completes,
        );
        await service.dispose();
      },
    );

    test(
      'playVoice completes without throwing when soundEnabled is false',
      () async {
        final service = AudioService(soundEnabled: false);
        await expectLater(
          service.playVoice('some_key', 'ar-EG'),
          completes,
        );
        await service.dispose();
      },
    );

    test(
      'stopAmbience completes without throwing when nothing is playing',
      () async {
        final service = AudioService(soundEnabled: true);
        await expectLater(service.stopAmbience(), completes);
        await service.dispose();
      },
    );

    test(
      'dispose completes without throwing',
      () async {
        final service = AudioService(soundEnabled: true);
        await expectLater(service.dispose(), completes);
      },
    );
  });
}
