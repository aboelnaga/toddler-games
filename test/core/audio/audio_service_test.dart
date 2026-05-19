import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/audio/audio_service.dart';

import '../../helpers/audio_test_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(registerAudioFakes);

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
