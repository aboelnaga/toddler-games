# Finger Paint Game (Slice 2) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Build the Finger Paint mini-game end-to-end — an AudioService backed by `audioplayers`, a `CustomPainter` drawing canvas, color palette, magic rainbow brush, long-press-to-clear, and router wiring — so that navigating to `/game/finger_paint` presents a fully playable drawing experience in both ar-EG and en locales.

**Architecture:** Three new layers added to the existing shell:
- `lib/core/audio/audio_service.dart` — a single `AudioService` class with three `AudioPlayer` instances (SFX, voice, ambience). A `Provider<AudioService>` recreates the service when `soundEnabled` toggles. All play calls are fire-and-forget wrapped in `unawaited()`, with silent `on Object catch` swallowing missing-file errors.
- `lib/features/games/finger_paint/` — self-contained feature folder. Pure-Dart models (`Stroke`, `PaintState`) with no code-gen. A `PaintNotifier extends Notifier<PaintState>` holds all mutation logic. UI widgets are `ConsumerWidget` / `ConsumerStatefulWidget` composed in `FingerPaintScreen` via a `Stack`.
- Router update in `lib/core/routing/router.dart` — adds a single `if (id == 'finger_paint')` branch, no structural changes needed.

**Tech Stack:** Flutter stable / Dart 3.11 · Riverpod 3 (`Notifier<S>`, `NotifierProvider`, `Provider`) · go_router 17 · `audioplayers ^6.0.0` (new dep) · `CustomPainter` + `RepaintBoundary` · `dart:ui` for `ui.Image` checkpoint · `very_good_analysis` lint enforced throughout.

**Companion docs:**
- [Product Requirements](../specs/2026-05-11-toddler-mini-games-prd.md)
- [Technical Design Spec](../specs/2026-05-11-toddler-mini-games-design.md)
- [Slice 0 plan](./2026-05-11-slice-0-scaffold-and-tooling.md)
- [Slice 1 plan](./2026-05-11-slice-1-app-shell.md)

**Pre-conditions:** Slice 1 complete. `slice-1-complete` git tag present. Running the app shows the home screen with 5 game tiles. Navigating to Finger Paint shows the placeholder screen.

---

## Hard invariants (copy from CLAUDE.md — never violate)

1. No network calls, no analytics SDKs.
2. No instrumental music (SFX + voice + ambience OK).
3. No fail states — mistakes silently ignored.
4. No in-game text the toddler must read.
5. Bilingual: ar-EG primary, en secondary.

---

## File Structure (what this slice creates or modifies)

```
pubspec.yaml                                          # add audioplayers ^6.0.0

lib/
  core/
    audio/
      audio_service.dart                              # CREATE — AudioService + audioServiceProvider

  features/games/
    finger_paint/
      models/
        stroke.dart                                   # CREATE — Stroke data class
        paint_state.dart                              # CREATE — PaintState + copyWith
      paint_notifier.dart                             # CREATE — PaintNotifier + paintProvider
      paint_canvas.dart                               # CREATE — ConsumerStatefulWidget canvas
      color_palette.dart                              # CREATE — color-circle row widget
      clear_button.dart                               # CREATE — long-press-to-clear widget
      magic_mode_button.dart                          # CREATE — sparkle toggle button
      finger_paint_screen.dart                        # CREATE — root screen widget

  core/routing/router.dart                            # MODIFY — add finger_paint branch

test/
  core/audio/
    audio_service_test.dart                           # CREATE

  features/games/finger_paint/
    paint_notifier_test.dart                          # CREATE
    finger_paint_screen_test.dart                     # CREATE

  golden/
    golden_test.dart                                  # MODIFY — add FingerPaintScreen group
    goldens/
      finger_paint_en.png                             # generated on first golden run
      finger_paint_ar.png                             # generated on first golden run
```

---

## Task 1: Add `audioplayers` dependency

**Files:**
- Modify: `pubspec.yaml`

- [x] **Step 1: Add the dependency**

Open `pubspec.yaml`. Under the `dependencies:` block, after `url_launcher: ^6.3.0`, add:

```yaml
  audioplayers: ^6.0.0
```

The full dependencies block after the change:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  audioplayers: ^6.0.0
  flutter_riverpod: ^3.0.0
  freezed_annotation: ^3.0.0
  go_router: ^17.0.0
  intl: ^0.20.2
  json_annotation: ^4.9.0
  package_info_plus: ^8.0.2
  riverpod_annotation: ^3.0.0
  shared_preferences: ^2.3.2
  url_launcher: ^6.3.0
```

- [x] **Step 2: Fetch the package**

```bash
flutter pub get
```

Expected output: `Got dependencies!` (no errors). If `audioplayers ^6.0.0` is unavailable, run `flutter pub outdated` to find the current stable version and adjust the constraint.

- [x] **Step 3: Verify the dependency is resolved**

```bash
grep "audioplayers" pubspec.lock
```

Expected: a line like `  audioplayers: 6.x.x` confirming resolution.

- [x] **Step 4: Commit**

```bash
git add pubspec.yaml pubspec.lock
git commit -m "chore: add audioplayers ^6.0.0 dependency"
```

---

## Task 2: AudioService — failing tests first

**Files:**
- Create: `test/core/audio/audio_service_test.dart`

- [x] **Step 1: Write the failing tests**

Create `test/core/audio/audio_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/audio/audio_service.dart';

void main() {
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
```

- [x] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/core/audio/audio_service_test.dart --reporter expanded
```

Expected: compilation error — `audio_service.dart` does not exist yet.

---

## Task 3: AudioService — implementation

**Files:**
- Create: `lib/core/audio/audio_service.dart`

- [x] **Step 1: Create the implementation**

Create `lib/core/audio/audio_service.dart`:

```dart
import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';

/// Wraps three [AudioPlayer] instances — one for SFX, one for voice, one for
/// looping ambience.  All play calls are fire-and-forget; errors from missing
/// asset files are swallowed silently so the app never crashes over audio.
///
/// The provider recreates this service when [soundEnabled] changes, so
/// [soundEnabled] is baked in at construction time rather than mutated.
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
  /// No-ops when [soundEnabled] is false or when the file is missing.
  Future<void> playSfx(String key) async {
    if (!soundEnabled) return;
    try {
      await _sfxPlayer.play(AssetSource('audio/sfx/$key.mp3'));
    } on Object {
      // Missing SFX file — silently ignore.
    }
  }

  /// Plays `assets/audio/voice/$localeId/$key.mp3`.
  /// No-ops when [soundEnabled] is false or when the file is missing.
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

/// Provides [AudioService] scoped to the current [soundEnabled] setting.
/// Recreated automatically whenever [soundEnabled] changes, ensuring the
/// baked-in flag stays in sync with user preferences.
final audioServiceProvider = Provider<AudioService>((ref) {
  final soundEnabled = ref.watch(
    settingsProvider.select((s) => s.soundEnabled),
  );
  final service = AudioService(soundEnabled: soundEnabled);
  ref.onDispose(service.dispose);
  return service;
});
```

- [x] **Step 2: Run tests and confirm they pass**

```bash
flutter test test/core/audio/audio_service_test.dart --reporter expanded
```

Expected: 5 tests pass. The `playSfx('nonexistent_file_that_does_not_exist')` test may take a moment since `audioplayers` tries to load the asset; it must complete without throwing.

- [x] **Step 3: Run full analyze**

```bash
flutter analyze lib/core/audio/audio_service.dart
```

Expected: No issues found.

- [x] **Step 4: Commit**

```bash
git add lib/core/audio/audio_service.dart \
        test/core/audio/audio_service_test.dart
git commit -m "feat: add AudioService wrapping audioplayers with silent error swallowing"
```

---

## Task 4: Stroke model — failing tests first

**Files:**
- Create: `test/features/games/finger_paint/paint_notifier_test.dart` (stub — will grow through Tasks 5–6)

**Note:** The Stroke model is pure data with no logic of its own. Its correctness is validated implicitly through `PaintNotifier` tests. We write the notifier tests first (they will fail because neither model nor notifier exists), then implement in Task 5–6.

- [x] **Step 1: Create the notifier test file**

Create `test/features/games/finger_paint/paint_notifier_test.dart`:

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/games/finger_paint/models/paint_state.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

ProviderContainer _makeContainer() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('PaintNotifier', () {
    test('initial state has empty strokes, empty activePoints, red color', () {
      final container = _makeContainer();
      final state = container.read(paintProvider);
      expect(state.completedStrokes, isEmpty);
      expect(state.activePoints, isEmpty);
      expect(state.activeColor, const Color(0xFFE53935));
      expect(state.magicMode, isFalse);
      expect(state.backgroundImage, isNull);
    });

    test('startStroke adds one point to activePoints', () {
      final container = _makeContainer();
      container.read(paintProvider.notifier).startStroke(const Offset(10, 20));
      final state = container.read(paintProvider);
      expect(state.activePoints, hasLength(1));
      expect(state.activePoints.first, const Offset(10, 20));
    });

    test('extendStroke appends points to activePoints', () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      notifier.startStroke(const Offset(0, 0));
      notifier.extendStroke(const Offset(5, 5));
      notifier.extendStroke(const Offset(10, 10));
      expect(container.read(paintProvider).activePoints, hasLength(3));
    });

    test('endStroke moves activePoints to completedStrokes and clears active',
        () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      notifier.startStroke(const Offset(0, 0));
      notifier.extendStroke(const Offset(5, 5));
      notifier.endStroke();
      final state = container.read(paintProvider);
      expect(state.completedStrokes, hasLength(1));
      expect(state.completedStrokes.first.points, hasLength(2));
      expect(state.activePoints, isEmpty);
    });

    test('endStroke preserves active color and magicMode in the created Stroke',
        () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      notifier.selectColor(const Color(0xFF1E88E5));
      notifier.toggleMagicMode();
      notifier.startStroke(const Offset(1, 1));
      notifier.endStroke();
      final stroke = container.read(paintProvider).completedStrokes.first;
      expect(stroke.color, const Color(0xFF1E88E5));
      expect(stroke.isMagic, isTrue);
    });

    test('selectColor updates activeColor', () {
      final container = _makeContainer();
      container
          .read(paintProvider.notifier)
          .selectColor(const Color(0xFF43A047));
      expect(
        container.read(paintProvider).activeColor,
        const Color(0xFF43A047),
      );
    });

    test('toggleMagicMode flips magicMode', () {
      final container = _makeContainer();
      expect(container.read(paintProvider).magicMode, isFalse);
      container.read(paintProvider.notifier).toggleMagicMode();
      expect(container.read(paintProvider).magicMode, isTrue);
      container.read(paintProvider.notifier).toggleMagicMode();
      expect(container.read(paintProvider).magicMode, isFalse);
    });

    test('clearCanvas resets strokes, activePoints, and backgroundImage', () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      notifier.startStroke(const Offset(0, 0));
      notifier.endStroke();
      notifier.clearCanvas();
      final state = container.read(paintProvider);
      expect(state.completedStrokes, isEmpty);
      expect(state.activePoints, isEmpty);
      expect(state.backgroundImage, isNull);
    });

    test('needsCheckpoint is false below 50 strokes', () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      for (var i = 0; i < 49; i++) {
        notifier.startStroke(Offset(i.toDouble(), 0));
        notifier.endStroke();
      }
      expect(container.read(paintProvider).needsCheckpoint, isFalse);
    });

    test('needsCheckpoint is true at exactly 50 strokes', () {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      for (var i = 0; i < 50; i++) {
        notifier.startStroke(Offset(i.toDouble(), 0));
        notifier.endStroke();
      }
      expect(container.read(paintProvider).needsCheckpoint, isTrue);
    });

    test(
        'applyCheckpoint stores backgroundImage and clears completedStrokes',
        () async {
      final container = _makeContainer();
      final notifier = container.read(paintProvider.notifier);
      notifier.startStroke(const Offset(0, 0));
      notifier.endStroke();

      // Create a tiny valid ui.Image for the test.
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
      final picture = recorder.endRecording();
      final image = await picture.toImage(1, 1);

      notifier.applyCheckpoint(image);
      final state = container.read(paintProvider);
      expect(state.backgroundImage, isNotNull);
      expect(state.completedStrokes, isEmpty);
    });
  });
}
```

- [x] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/features/games/finger_paint/paint_notifier_test.dart \
  --reporter expanded
```

Expected: compilation error — `paint_state.dart` and `paint_notifier.dart` do not exist yet.

---

## Task 5: Stroke and PaintState models

**Files:**
- Create: `lib/features/games/finger_paint/models/stroke.dart`
- Create: `lib/features/games/finger_paint/models/paint_state.dart`

- [x] **Step 1: Create `stroke.dart`**

Create `lib/features/games/finger_paint/models/stroke.dart`:

```dart
import 'package:flutter/material.dart';

/// A single drawn path.
///
/// [isMagic] causes the renderer to cycle HSV hue along the path
/// instead of using a flat [color].
class Stroke {
  const Stroke({
    required this.points,
    required this.color,
    this.strokeWidth = 14,
    this.isMagic = false,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool isMagic;
}
```

- [x] **Step 2: Create `paint_state.dart`**

Create `lib/features/games/finger_paint/models/paint_state.dart`:

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';

/// Immutable state for the finger paint game.
///
/// [completedStrokes] holds strokes where the finger has been lifted.
/// [activePoints] holds the in-progress gesture points.
/// [backgroundImage] is a checkpointed bitmap — null until first checkpoint.
/// When [needsCheckpoint] is true, the canvas widget should flatten
/// [completedStrokes] onto [backgroundImage] to reclaim memory.
class PaintState {
  const PaintState({
    this.completedStrokes = const [],
    this.activePoints = const [],
    this.activeColor = const Color(0xFFE53935),
    this.magicMode = false,
    this.backgroundImage,
  });

  final List<Stroke> completedStrokes;
  final List<Offset> activePoints;
  final Color activeColor;
  final bool magicMode;
  final ui.Image? backgroundImage;

  bool get needsCheckpoint => completedStrokes.length >= 50;

  PaintState copyWith({
    List<Stroke>? completedStrokes,
    List<Offset>? activePoints,
    Color? activeColor,
    bool? magicMode,
    ui.Image? backgroundImage,
    bool clearBackgroundImage = false,
  }) {
    return PaintState(
      completedStrokes: completedStrokes ?? this.completedStrokes,
      activePoints: activePoints ?? this.activePoints,
      activeColor: activeColor ?? this.activeColor,
      magicMode: magicMode ?? this.magicMode,
      backgroundImage: clearBackgroundImage
          ? null
          : (backgroundImage ?? this.backgroundImage),
    );
  }
}
```

**Note on `copyWith` design:** `ui.Image?` cannot be set back to `null` via the normal `??` pattern since `null` is a valid target value. The `clearBackgroundImage` flag solves this without breaking the immutability pattern.

- [x] **Step 3: Verify compilation (no tests yet — models are pure data)**

```bash
flutter analyze \
  lib/features/games/finger_paint/models/stroke.dart \
  lib/features/games/finger_paint/models/paint_state.dart
```

Expected: No issues found.

---

## Task 6: PaintNotifier implementation

**Files:**
- Create: `lib/features/games/finger_paint/paint_notifier.dart`

- [x] **Step 1: Create `paint_notifier.dart`**

Create `lib/features/games/finger_paint/paint_notifier.dart`:

```dart
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/features/games/finger_paint/models/paint_state.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';

class PaintNotifier extends Notifier<PaintState> {
  @override
  PaintState build() => const PaintState();

  /// Begins a new in-progress stroke at [point].
  void startStroke(Offset point) {
    state = state.copyWith(activePoints: [point]);
  }

  /// Appends [point] to the current in-progress stroke.
  void extendStroke(Offset point) {
    state = state.copyWith(
      activePoints: [...state.activePoints, point],
    );
  }

  /// Finalises the in-progress stroke and adds it to [PaintState.completedStrokes].
  void endStroke() {
    if (state.activePoints.isEmpty) return;
    final newStroke = Stroke(
      points: List.unmodifiable(state.activePoints),
      color: state.activeColor,
      isMagic: state.magicMode,
    );
    state = state.copyWith(
      completedStrokes: [...state.completedStrokes, newStroke],
      activePoints: [],
    );
  }

  /// Changes the active paint color.
  void selectColor(Color color) {
    state = state.copyWith(activeColor: color);
  }

  /// Toggles the rainbow magic brush on or off.
  void toggleMagicMode() {
    state = state.copyWith(magicMode: !state.magicMode);
  }

  /// Stores a checkpointed bitmap and discards the completed strokes that
  /// have been baked into it, reclaiming memory.
  void applyCheckpoint(ui.Image image) {
    state = state.copyWith(
      backgroundImage: image,
      completedStrokes: [],
    );
  }

  /// Wipes the canvas completely — strokes, active points, and checkpoint.
  void clearCanvas() {
    state = const PaintState(
      completedStrokes: [],
      activePoints: [],
      backgroundImage: null,
    );
  }
}

final paintProvider = NotifierProvider<PaintNotifier, PaintState>(
  PaintNotifier.new,
);
```

- [x] **Step 2: Run the notifier tests**

```bash
flutter test test/features/games/finger_paint/paint_notifier_test.dart \
  --reporter expanded
```

Expected: all tests pass.

- [x] **Step 3: Run analyze**

```bash
flutter analyze lib/features/games/finger_paint/
```

Expected: No issues found.

- [x] **Step 4: Commit**

```bash
git add \
  lib/features/games/finger_paint/models/stroke.dart \
  lib/features/games/finger_paint/models/paint_state.dart \
  lib/features/games/finger_paint/paint_notifier.dart \
  test/features/games/finger_paint/paint_notifier_test.dart
git commit -m "feat: add Stroke, PaintState models and PaintNotifier with full test coverage"
```

---

## Task 7: PaintCanvas widget

**Files:**
- Create: `lib/features/games/finger_paint/paint_canvas.dart`

- [x] **Step 1: Create `paint_canvas.dart`**

Create `lib/features/games/finger_paint/paint_canvas.dart`:

```dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/features/games/finger_paint/models/paint_state.dart';
import 'package:toddler_games/features/games/finger_paint/models/stroke.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

class PaintCanvas extends ConsumerStatefulWidget {
  const PaintCanvas({super.key});

  @override
  ConsumerState<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends ConsumerState<PaintCanvas> {
  final _repaintBoundaryKey = GlobalKey();
  bool _checkpointScheduled = false;

  void _scheduleCheckpoint() {
    if (_checkpointScheduled) return;
    _checkpointScheduled = true;
    unawaited(
      WidgetsBinding.instance.endOfFrame.then((_) async {
        _checkpointScheduled = false;
        if (!mounted) return;
        final boundary = _repaintBoundaryKey.currentContext
            ?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary == null) return;
        final pixelRatio =
            View.of(context).devicePixelRatio;
        final ui.Image image = await boundary.toImage(
          pixelRatio: pixelRatio,
        );
        if (!mounted) return;
        ref.read(paintProvider.notifier).applyCheckpoint(image);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paintProvider);
    final notifier = ref.read(paintProvider.notifier);
    final audio = ref.read(audioServiceProvider);

    if (state.needsCheckpoint) {
      _scheduleCheckpoint();
    }

    return GestureDetector(
      onPanStart: (details) {
        notifier.startStroke(details.localPosition);
        unawaited(audio.playSfx('paint_brush_start'));
      },
      onPanUpdate: (details) {
        notifier.extendStroke(details.localPosition);
      },
      onPanEnd: (_) {
        notifier.endStroke();
      },
      child: RepaintBoundary(
        key: _repaintBoundaryKey,
        child: CustomPaint(
          painter: _PaintCanvasPainter(state: state),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _PaintCanvasPainter extends CustomPainter {
  const _PaintCanvasPainter({required this.state});

  final PaintState state;

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw the flattened background image (checkpoint), if any.
    if (state.backgroundImage != null) {
      canvas.drawImage(state.backgroundImage!, Offset.zero, Paint());
    }

    // 2. Draw all completed strokes.
    for (final stroke in state.completedStrokes) {
      _drawStroke(canvas, stroke);
    }

    // 3. Draw the active (in-progress) points as a live stroke.
    if (state.activePoints.length >= 2) {
      final liveStroke = Stroke(
        points: state.activePoints,
        color: state.activeColor,
        isMagic: state.magicMode,
      );
      _drawStroke(canvas, liveStroke);
    }
  }

  void _drawStroke(Canvas canvas, Stroke stroke) {
    if (stroke.points.length < 2) return;
    final total = stroke.points.length;
    for (var i = 0; i < total - 1; i++) {
      final paint = Paint()
        ..color = stroke.isMagic
            ? HSVColor.fromAHSV(
                1,
                (i / total) * 360,
                1,
                1,
              ).toColor()
            : stroke.color
        ..strokeWidth = stroke.strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PaintCanvasPainter oldDelegate) => true;
}
```

- [x] **Step 2: Run analyze**

```bash
flutter analyze lib/features/games/finger_paint/paint_canvas.dart
```

Expected: No issues found.

---

## Task 8: ColorPalette widget

**Files:**
- Create: `lib/features/games/finger_paint/color_palette.dart`

- [x] **Step 1: Create `color_palette.dart`**

Create `lib/features/games/finger_paint/color_palette.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// The 8 paint colors available to the child.
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
///
/// [selectedColor] receives a white border ring.
/// [onColorSelected] is called with the tapped color.
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
        final isSelected = color.value == selectedColor.value;
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
```

- [x] **Step 2: Run analyze**

```bash
flutter analyze lib/features/games/finger_paint/color_palette.dart
```

Expected: No issues found.

---

## Task 9: ClearButton widget

**Files:**
- Create: `lib/features/games/finger_paint/clear_button.dart`

- [x] **Step 1: Create `clear_button.dart`**

Create `lib/features/games/finger_paint/clear_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// A trash-can button that clears the canvas after the user holds it for
/// 2 seconds. Shows a circular progress indicator as the user holds.
///
/// There is no fail state — releasing before 2 seconds simply cancels.
class ClearButton extends StatefulWidget {
  const ClearButton({required this.onClear, super.key});

  final VoidCallback onClear;

  @override
  State<ClearButton> createState() => _ClearButtonState();
}

class _ClearButtonState extends State<ClearButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onClear();
          _controller.reset();
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (_) => _controller.forward(),
      onLongPressEnd: (_) => _controller.reset(),
      onLongPressCancel: () => _controller.reset(),
      child: SizedBox(
        width: DesignTokens.minTouchTarget,
        height: DesignTokens.minTouchTarget,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                if (_controller.value > 0)
                  CircularProgressIndicator(
                    value: _controller.value,
                    strokeWidth: 4,
                    color: Colors.redAccent,
                  ),
                child!,
              ],
            );
          },
          child: const Icon(
            Icons.delete_outline_rounded,
            size: 32,
            color: DesignTokens.textSecondary,
          ),
        ),
      ),
    );
  }
}
```

- [x] **Step 2: Run analyze**

```bash
flutter analyze lib/features/games/finger_paint/clear_button.dart
```

Expected: No issues found.

---

## Task 10: MagicModeButton widget

**Files:**
- Create: `lib/features/games/finger_paint/magic_mode_button.dart`

- [x] **Step 1: Create `magic_mode_button.dart`**

Create `lib/features/games/finger_paint/magic_mode_button.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// Sparkle icon button that toggles the rainbow magic brush.
///
/// When [isActive], the button shows with an orange filled background.
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
```

- [x] **Step 2: Run analyze**

```bash
flutter analyze lib/features/games/finger_paint/magic_mode_button.dart
```

Expected: No issues found.

---

## Task 11: FingerPaintScreen — failing widget tests first

**Files:**
- Create: `test/features/games/finger_paint/finger_paint_screen_test.dart`

- [x] **Step 1: Write the failing widget tests**

Create `test/features/games/finger_paint/finger_paint_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/games/finger_paint/color_palette.dart';
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
import 'package:toddler_games/features/games/finger_paint/magic_mode_button.dart';
import 'package:toddler_games/features/games/finger_paint/paint_canvas.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

/// Wraps a widget with all providers the FingerPaintScreen needs.
Widget _wrap(
  Widget child, {
  required ProviderContainer container,
  String initialRoute = '/',
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, _) => child)],
      ),
    ),
  );
}

Future<ProviderContainer> _makeContainer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  group('FingerPaintScreen', () {
    testWidgets('renders PaintCanvas', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PaintCanvas), findsOneWidget);
    });

    testWidgets('renders ColorPalette', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ColorPalette), findsOneWidget);
    });

    testWidgets('renders home button with home icon', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('renders MagicModeButton', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MagicModeButton), findsOneWidget);
    });

    testWidgets('renders ClearButton (delete icon)', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
    });

    testWidgets('tapping a color circle updates activeColor in PaintNotifier',
        (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();

      // The orange circle is index 1 in kPaletteColors (0xFF_FB8C00).
      // Find the second color circle by its Container with that color.
      final orangeCircle = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).color ==
                const Color(0xFFFB8C00),
      );
      await tester.tap(orangeCircle.first);
      await tester.pump();

      expect(
        container.read(paintProvider).activeColor,
        const Color(0xFFFB8C00),
      );
    });

    testWidgets('tapping MagicModeButton toggles magicMode', (tester) async {
      final container = await _makeContainer();
      await tester.pumpWidget(
        _wrap(const FingerPaintScreen(), container: container),
      );
      await tester.pumpAndSettle();

      expect(container.read(paintProvider).magicMode, isFalse);
      await tester.tap(find.byType(MagicModeButton));
      await tester.pump();
      expect(container.read(paintProvider).magicMode, isTrue);
    });
  });
}
```

- [x] **Step 2: Run tests to confirm they fail**

```bash
flutter test test/features/games/finger_paint/finger_paint_screen_test.dart \
  --reporter expanded
```

Expected: compilation error — `finger_paint_screen.dart` does not exist yet.

---

## Task 12: FingerPaintScreen implementation

**Files:**
- Create: `lib/features/games/finger_paint/finger_paint_screen.dart`

- [x] **Step 1: Create `finger_paint_screen.dart`**

Create `lib/features/games/finger_paint/finger_paint_screen.dart`:

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/audio/audio_service.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/games/finger_paint/clear_button.dart';
import 'package:toddler_games/features/games/finger_paint/color_palette.dart';
import 'package:toddler_games/features/games/finger_paint/magic_mode_button.dart';
import 'package:toddler_games/features/games/finger_paint/paint_canvas.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';

class FingerPaintScreen extends ConsumerWidget {
  const FingerPaintScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(paintProvider.notifier);
    final audio = ref.read(audioServiceProvider);
    final selectedColor = ref.watch(
      paintProvider.select((s) => s.activeColor),
    );
    final magicMode = ref.watch(
      paintProvider.select((s) => s.magicMode),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Full-screen drawing canvas.
            const Positioned.fill(child: PaintCanvas()),

            // Top-left: home button.
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

            // Top-right: magic brush toggle.
            Positioned(
              top: DesignTokens.space2,
              right: DesignTokens.space2,
              child: MagicModeButton(
                isActive: magicMode,
                onToggle: () {
                  notifier.toggleMagicMode();
                  unawaited(audio.playSfx('paint_magic_on'));
                },
              ),
            ),

            // Bottom-center: color palette strip.
            Positioned(
              bottom: DesignTokens.space3,
              left: 0,
              right: 0,
              child: Center(
                child: _PaletteCard(
                  child: ColorPalette(
                    selectedColor: selectedColor,
                    onColorSelected: (color) {
                      notifier.selectColor(color);
                      unawaited(audio.playSfx('paint_select_color'));
                    },
                  ),
                ),
              ),
            ),

            // Bottom-right: long-press-to-clear trash button.
            Positioned(
              bottom: DesignTokens.space3,
              right: DesignTokens.space3,
              child: ClearButton(
                onClear: () {
                  notifier.clearCanvas();
                  unawaited(audio.playSfx('paint_canvas_clear'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Semi-transparent white circle background for overlay icon buttons.
class _CircleOverlayButton extends StatelessWidget {
  const _CircleOverlayButton({
    required this.onTap,
    required this.child,
  });

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

/// Rounded card background for the color palette strip.
class _PaletteCard extends StatelessWidget {
  const _PaletteCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space3,
        vertical: DesignTokens.space2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(DesignTokens.radiusXL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
```

- [x] **Step 2: Run the widget tests**

```bash
flutter test test/features/games/finger_paint/finger_paint_screen_test.dart \
  --reporter expanded
```

Expected: all 7 tests pass.

- [x] **Step 3: Run analyze over the full feature folder**

```bash
flutter analyze lib/features/games/finger_paint/
```

Expected: No issues found.

- [x] **Step 4: Commit**

```bash
git add \
  lib/features/games/finger_paint/paint_canvas.dart \
  lib/features/games/finger_paint/color_palette.dart \
  lib/features/games/finger_paint/clear_button.dart \
  lib/features/games/finger_paint/magic_mode_button.dart \
  lib/features/games/finger_paint/finger_paint_screen.dart \
  test/features/games/finger_paint/finger_paint_screen_test.dart
git commit -m "feat: add FingerPaintScreen, PaintCanvas, ColorPalette, ClearButton, MagicModeButton"
```

---

## Task 13: Router wiring

**Files:**
- Modify: `lib/core/routing/router.dart` (the `/game/:id` builder)

- [x] **Step 1: Add the `finger_paint` branch to the router**

In `lib/core/routing/router.dart`, locate the `/game/:id` route (lines 24–29). Replace the builder with:

```dart
GoRoute(
  path: '/game/:id',
  builder: (context, state) {
    final id = state.pathParameters['id']!;
    if (id == 'finger_paint') return const FingerPaintScreen();
    return PlaceholderGameScreen(gameId: id);
  },
),
```

Also add the import at the top of the file (after existing imports, maintaining sort order):

```dart
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
```

The full updated import block at the top of `router.dart` (only changed lines shown):

```dart
import 'package:toddler_games/features/games/_placeholder/placeholder_game_screen.dart';
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
import 'package:toddler_games/features/home/home_screen.dart';
```

- [x] **Step 2: Analyze the router file**

```bash
flutter analyze lib/core/routing/router.dart
```

Expected: No issues found.

- [x] **Step 3: Smoke-test routing in the widget test for shell flow**

```bash
flutter test test/app/view/shell_flow_test.dart --reporter expanded
```

Expected: existing shell_flow test passes (it doesn't touch the finger_paint route but it validates the router still works).

- [x] **Step 4: Commit**

```bash
git add lib/core/routing/router.dart
git commit -m "feat: wire /game/finger_paint route to FingerPaintScreen"
```

---

## Task 14: Full test suite verification

- [x] **Step 1: Run all non-golden tests**

```bash
flutter test --exclude-tags golden --reporter expanded
```

Expected: all tests pass. Typical count after this slice: ~65 tests (the existing 56 from Slice 1 + the new audio, notifier, and screen tests from this slice).

- [x] **Step 2: Run flutter analyze on the whole project**

```bash
flutter analyze
```

Expected: No issues found.

- [x] **Step 3: Run dart format check**

```bash
dart format --set-exit-if-changed lib/ test/
```

Expected: Exit code 0 (no unformatted files). If it reports changes, run `dart format lib/ test/` then re-check.

- [x] **Step 4: Run custom_lint**

```bash
dart run custom_lint
```

Expected: No issues found.

- [x] **Step 5: Commit if any formatting-only changes were needed**

Only commit if Step 3 required formatting changes:

```bash
git add -u
git commit -m "style: dart format after slice-2 implementation"
```

---

## Task 15: Golden tests for FingerPaintScreen

**Files:**
- Modify: `test/golden/golden_test.dart` — add FingerPaintScreen group
- Generated: `test/golden/goldens/finger_paint_en.png`
- Generated: `test/golden/goldens/finger_paint_ar.png`

**Note on golden workflow:** The first run with `--update-goldens` generates the `.png` reference files. The second run (without the flag) is the pass/fail check. Both generated `.png` files must be committed.

- [x] **Step 1: Add the FingerPaintScreen golden group to `golden_test.dart`**

Open `test/golden/golden_test.dart`. Add the following import alongside the existing ones (maintain alphabetical sort):

```dart
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
import 'package:toddler_games/features/games/finger_paint/paint_notifier.dart';
```

Append the following group at the end of `main()`, before the closing `}`:

```dart
  group('FingerPaintScreen', () {
    testWidgets('en golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      // Override paintProvider with a clean state for deterministic output.
      final paintContainer = ProviderContainer(
        parent: container,
        overrides: [
          paintProvider.overrideWith(PaintNotifier.new),
        ],
      );
      addTearDown(paintContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const FingerPaintScreen(),
          locale: _en,
          container: paintContainer,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FingerPaintScreen),
        matchesGoldenFile('goldens/finger_paint_en.png'),
      );
    });

    testWidgets('ar golden', (tester) async {
      _setPhoneViewport(tester);
      addTearDown(tester.view.reset);

      final container = await _makeContainer();
      addTearDown(container.dispose);

      final paintContainer = ProviderContainer(
        parent: container,
        overrides: [
          paintProvider.overrideWith(PaintNotifier.new),
        ],
      );
      addTearDown(paintContainer.dispose);

      await tester.pumpWidget(
        _wrap(
          const FingerPaintScreen(),
          locale: _ar,
          container: paintContainer,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(FingerPaintScreen),
        matchesGoldenFile('goldens/finger_paint_ar.png'),
      );
    });
  });
```

- [x] **Step 2: Generate the reference golden files (macOS only)**

```bash
flutter test test/golden/golden_test.dart --tags golden --update-goldens
```

Expected: two new `.png` files appear in `test/golden/goldens/`:
- `finger_paint_en.png`
- `finger_paint_ar.png`

- [x] **Step 3: Run goldens without update flag to confirm they pass**

```bash
flutter test test/golden/golden_test.dart --tags golden --reporter expanded
```

Expected: all 8 golden tests pass (6 existing + 2 new).

- [x] **Step 4: Commit**

```bash
git add \
  test/golden/golden_test.dart \
  test/golden/goldens/finger_paint_en.png \
  test/golden/goldens/finger_paint_ar.png
git commit -m "test: add FingerPaintScreen golden tests for en and ar locales"
```

---

## Task 16: Audio placeholder note and final tag

**No code change needed.** This task documents the audio placeholder strategy and tags the slice.

**Audio asset strategy:** The four SFX keys used in this slice (`paint_brush_start`, `paint_select_color`, `paint_canvas_clear`, `paint_magic_on`) have no corresponding files in `assets/audio/sfx/`. This is intentional. `AudioService.playSfx` wraps every play call in `on Object catch` and silently swallows missing-file errors. The game is fully playable without sound files. When real SFX are recorded, drop `.mp3` files with the matching key names into `assets/audio/sfx/` and they will be picked up automatically with no code change.

**Voice clips** for this game are also absent. The Finger Paint game does not currently trigger voice playback — that is a future enhancement (e.g., "احلى رسمة!" celebration on first stroke, deferred to Slice 2b or a polish pass).

- [x] **Step 1: Run the complete non-golden test suite one final time**

```bash
flutter test --exclude-tags golden
```

Expected: all tests pass.

- [x] **Step 2: Tag the slice**

```bash
git tag slice-2-complete
```

- [x] **Step 3: Update the ROADMAP to reflect slice-2 complete**

Open `docs/superpowers/ROADMAP.md`. In the slice table, change the Slice 2 row from:

```
| 2 | Game 1: Tap-to-Discover Zoo | not yet written | **Plan pending** | ...
```

to:

```
| 2 | Game 1: Finger Paint | [plan](plans/2026-05-19-slice-2-finger-paint.md) | **Complete** (tag: `slice-2-complete`) | AudioService, CustomPainter canvas, color palette, magic rainbow brush, long-press clear; goldens in both locales |
```

Also update the "Next action" section to point to Slice 3 (Bubble Pop) or the remaining skeleton plans.

- [x] **Step 4: Commit the roadmap update**

```bash
git add docs/superpowers/ROADMAP.md
git commit -m "docs: mark slice-2 finger-paint complete in roadmap"
```

---

---

## Post-completion notes (2026-05-20)

### ClearButton: GestureDetector → Listener

**Problem found during live use:** `GestureDetector.onLongPressStart` has a mandatory 500 ms recognition window with zero visual feedback. In practice, users pressed the button and released before 500 ms elapsed, received `onLongPressCancel` with no visible response, and concluded the button was broken. Diagnostic logs (`Listener.onPointerDown/Up` + `debugPrint` on every gesture callback) confirmed this: every press showed `pointer DOWN → pointer UP → onLongPressCancel` with the pointer up happening before the long-press timer fired.

**Fix applied:** Replaced `GestureDetector` in `clear_button.dart` with a raw `Listener`. `onPointerDown` now calls `_controller.forward()` immediately, starting the progress ring the instant the user touches the button. `onPointerUp` and `onPointerCancel` reset the controller. The animation still takes 2 seconds to complete before `onClear` fires — only the feedback latency changed (from 500 ms to 0 ms).

**Files changed:** `lib/features/games/finger_paint/clear_button.dart` (Task 9 implementation replaced in-place; Task 9 plan text reflects the original design but the live code is the Listener version).

**Note for future implementers:** The spec (`plan §4.4`) describes "a gentle two-second hold" — the fix honours this intention. The difference is purely in UX: immediate visual confirmation vs. invisible waiting period.

---

## Self-review checklist

### Spec coverage

| Spec requirement | Covered by task |
|---|---|
| `audioplayers ^6.0.0` added | Task 1 |
| `AudioService` with 3 players | Task 3 |
| `playSfx` no-ops on `soundEnabled=false` | Task 3 + Task 2 tests |
| `playSfx` swallows missing-file errors | Task 3 + Task 2 tests |
| `playVoice`, `playAmbience`, `stopAmbience`, `dispose` | Task 3 |
| `audioServiceProvider` recreates on settings change | Task 3 |
| `Stroke` model with `isMagic` | Task 5 |
| `PaintState` with `copyWith`, `needsCheckpoint` | Task 5 |
| `PaintNotifier.startStroke / extendStroke / endStroke` | Task 6 |
| `PaintNotifier.selectColor / toggleMagicMode` | Task 6 |
| `PaintNotifier.applyCheckpoint / clearCanvas` | Task 6 |
| `paintProvider = NotifierProvider` | Task 6 |
| `PaintCanvas` with `RepaintBoundary` + `GlobalKey` | Task 7 |
| Checkpoint logic via `needsCheckpoint` + post-frame callback | Task 7 |
| Magic stroke HSV hue cycling | Task 7 |
| Normal stroke polyline with round caps | Task 7 |
| `GestureDetector` with pan callbacks + SFX | Task 7 |
| `ColorPalette` with 8 colors, 52dp circles | Task 8 |
| Selected color gets white border ring | Task 8 |
| `ClearButton` long-press 2s with progress ring | Task 9 |
| `MagicModeButton` with active highlight | Task 10 |
| `FingerPaintScreen` Stack layout | Task 12 |
| Home button top-left | Task 12 |
| MagicModeButton top-right | Task 12 |
| ColorPalette bottom-center | Task 12 |
| ClearButton bottom-right | Task 12 |
| SFX on color select, magic toggle, clear | Task 12 |
| Router wiring `finger_paint` → `FingerPaintScreen` | Task 13 |
| Widget tests for screen | Task 11 + 12 |
| Notifier unit tests (all 9 scenarios) | Task 4 + 6 |
| Audio service tests | Task 2 + 3 |
| `@Tags(['golden'])` golden tests in en + ar | Task 15 |
| `very_good_analysis` lint compliance | Tasks 3, 5, 6, 7, 8, 9, 10, 12 |
| No text the toddler reads in-game | Task 12 (icons only) |
| No fail states | Tasks 9, 7 (silent ignore on short strokes) |
| No network calls | AudioService uses `AssetSource`, not `UrlSource` |
| Bilingual (ar-EG primary) | Golden tests cover both locales |

### No placeholder scan

Reviewed: no "TBD", "TODO", "implement later", or "Similar to Task N" patterns found. Every code step shows complete file content.

### Type consistency

- `Stroke` defined in Task 5, used in Tasks 6, 7 — field names consistent (`points`, `color`, `strokeWidth`, `isMagic`).
- `PaintState` defined in Task 5, used in Tasks 6, 7, 11, 12 — field names consistent (`completedStrokes`, `activePoints`, `activeColor`, `magicMode`, `backgroundImage`, `needsCheckpoint`).
- `PaintNotifier` methods defined in Task 6: `startStroke`, `extendStroke`, `endStroke`, `selectColor`, `toggleMagicMode`, `applyCheckpoint`, `clearCanvas` — used consistently in Tasks 7, 12, and tests in Tasks 4, 11.
- `AudioService` methods: `playSfx`, `playVoice`, `playAmbience`, `stopAmbience`, `dispose` — consistent between Task 3 impl and Task 2 tests and Task 12 usages.
- `paintProvider` defined in Task 6, used in Tasks 7, 11, 12, 15.
- `audioServiceProvider` defined in Task 3, used in Tasks 7, 12.
- `ClearButton({required this.onClear, super.key})` defined Task 9, used in Task 12 as `ClearButton(onClear: () {...})` — consistent.
- `MagicModeButton({required this.isActive, required this.onToggle, super.key})` defined Task 10, used in Task 12 — consistent.
- `ColorPalette({required this.selectedColor, required this.onColorSelected, super.key})` defined Task 8, used in Task 12 — consistent.
- `kPaletteColors` const defined in Task 8, used by the test in Task 11 for color lookup — consistent.
