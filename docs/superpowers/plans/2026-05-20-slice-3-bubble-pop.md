# Bubble Pop Game (Slice 3) Implementation Plan

> **For agentic workers:** This is a medium-depth plan for Slice 3 (per ROADMAP decision: full plans for Slices 0–2, lighter for 3–7). Each task lists files, the key code sketch, and exact verification commands. Where code blocks are abbreviated, follow the existing patterns from the Finger Paint slice (`lib/features/games/finger_paint/`).

**Goal:** Build the Bubble Pop mini-game end-to-end. Coloured bubbles drift upward at varied speeds and sizes. Tap a bubble → it pops with a sound effect and a brief sparkle. New bubbles spawn continuously. No fail state, no score, no clock.

**Architecture:**
- `lib/features/games/bubble_pop/` — self-contained feature folder, mirroring the shape of `finger_paint/`.
- `models/bubble.dart` — immutable `Bubble` data class (id, position, radius, color, velocityY).
- `models/bubble_pop_state.dart` — `BubblePopState(bubbles, lastSpawnSeconds)` with `copyWith`.
- `bubble_notifier.dart` — `BubbleNotifier extends Notifier<BubblePopState>` with `tick(double dtSeconds, Size canvasSize)`, `spawn(Size canvasSize)`, `pop(int id)`, `reset()`. A seedable `Random` is injected via constructor for deterministic tests.
- `bubble_view.dart` — single bubble widget: a `Positioned` + `GestureDetector` wrapping a `CustomPaint` circle with a highlight.
- `bubble_pop_screen.dart` — root `ConsumerStatefulWidget`. Owns a `Ticker` that calls `notifier.tick(dt, canvasSize)` every frame. Stack of bubble widgets + home button overlay.
- Router: add `if (id == 'bubble_pop') return const BubblePopScreen();` branch.

**Tech stack:** Flutter stable / Dart 3.x · Riverpod 3 (`Notifier<S>`, `NotifierProvider`) · go_router 17 · `Ticker` (via `SingleTickerProviderStateMixin`) · `CustomPainter` for bubble visual · existing `AudioService` from Slice 2.

**Companion docs:**
- [Product Requirements §4.2](../specs/2026-05-11-toddler-mini-games-prd.md)
- [Technical Design Spec §3.2, §9.2](../specs/2026-05-11-toddler-mini-games-design.md)
- [Slice 2 plan (precedent for game-feature layout, AudioService usage, golden tests)](./2026-05-19-slice-2-finger-paint.md)

**Pre-conditions:** Slices 0/1/2 complete. `slice-2-complete` git tag present. `AudioService` exists in `lib/core/audio/audio_service.dart`. Home screen renders 5 tiles; tapping the Bubble Pop tile currently shows the placeholder.

---

## Hard invariants (copy from CLAUDE.md — never violate)

1. No network calls, no analytics SDKs.
2. No instrumental music (SFX + voice + ambience OK).
3. No fail states — mistakes silently ignored. Misses do nothing; off-screen bubbles silently disappear.
4. No in-game text the toddler must read.
5. Bilingual: ar-EG primary, en secondary (only the home button affects locale here — bubbles are language-free).

---

## File structure (what this slice creates or modifies)

```
lib/features/games/bubble_pop/
  models/
    bubble.dart                    # CREATE — immutable Bubble data
    bubble_pop_state.dart          # CREATE — BubblePopState + copyWith
  bubble_notifier.dart             # CREATE — Notifier + provider
  bubble_view.dart                 # CREATE — single bubble Positioned widget
  bubble_pop_screen.dart           # CREATE — root screen + Ticker

lib/core/routing/router.dart       # MODIFY — add bubble_pop branch + import

test/features/games/bubble_pop/
  bubble_notifier_test.dart        # CREATE — unit tests for spawn/tick/pop
  bubble_pop_screen_test.dart      # CREATE — widget tests

test/golden/
  golden_test.dart                 # MODIFY — add BubblePopScreen group
  goldens/
    bubble_pop_en.png              # generated on first golden run
    bubble_pop_ar.png              # generated on first golden run
```

---

## Game-design constants (locked in this slice)

These live as `static const` on a private `_BubbleConfig` class inside `bubble_notifier.dart` (or as top-level `const` in the file). Adjustable later, but pin them now so tests are stable:

- Bubble palette: 6 colors — red `0xFFE53935`, orange `0xFFFB8C00`, yellow `0xFFFDD835`, green `0xFF43A047`, blue `0xFF1E88E5`, purple `0xFF8E24AA`.
- Radius range: 36 – 64 px.
- Vertical velocity range: 40 – 90 px/sec (upward — y decreases).
- Spawn interval range: 0.4 – 1.1 sec (drawn fresh after each spawn).
- Max concurrent bubbles: 24 (skip spawn if already at cap).
- Off-screen removal: when bubble's top edge (y - radius) ≤ -20 px.

---

## Task 1: Bubble + BubblePopState models

**Files:** create `lib/features/games/bubble_pop/models/bubble.dart`, `lib/features/games/bubble_pop/models/bubble_pop_state.dart`.

- [ ] **Step 1.** Create `bubble.dart` with an immutable `Bubble` class: `final int id`, `final Offset position`, `final double radius`, `final Color color`, `final double velocityY`. A `copyWith` for `position` (so `tick` can advance positions). Override `==` and `hashCode` on `id` only so list diffs are cheap.

- [ ] **Step 2.** Create `bubble_pop_state.dart`:
  ```dart
  class BubblePopState {
    const BubblePopState({this.bubbles = const [], this.secondsUntilNextSpawn = 0});
    final List<Bubble> bubbles;
    final double secondsUntilNextSpawn;
    BubblePopState copyWith({List<Bubble>? bubbles, double? secondsUntilNextSpawn});
  }
  ```

- [ ] **Step 3.** Verify:
  ```bash
  flutter analyze lib/features/games/bubble_pop/models/
  ```
  Expected: No issues found.

---

## Task 2: BubbleNotifier — tests first

**Files:** create `test/features/games/bubble_pop/bubble_notifier_test.dart`.

Cover these scenarios — all using a `BubbleNotifier` with a fixed-seed `Random` injected via `NotifierProvider.overrideWith` or via a separately constructible factory. The notifier needs a `seedFactory` parameter so tests can pin randomness.

- [ ] **Initial state**: `bubbles` is empty; `secondsUntilNextSpawn` is 0.
- [ ] **`spawn(Size(400, 800))`** adds one bubble inside the canvas: `0 ≤ x ≤ 400`, `position.y` is just below the bottom edge (y ≈ 800 + radius), radius in [36, 64], color is one of the palette, velocityY in [40, 90].
- [ ] **`tick(dt, size)`** moves bubble y up by `velocityY * dt`. For a bubble starting at y=800 with velocity=100, after `tick(1.0, …)` it should be at y=700.
- [ ] **`tick` removes off-screen bubbles** (when `position.y + radius < -20`).
- [ ] **`tick` triggers spawn** when `secondsUntilNextSpawn ≤ 0`, then resets `secondsUntilNextSpawn` to a value in `[0.4, 1.1]`.
- [ ] **Spawn cap**: with 24 bubbles already present, `tick` does NOT spawn, even if `secondsUntilNextSpawn ≤ 0`.
- [ ] **`pop(id)`** removes the bubble with matching id; popping a missing id is a no-op.
- [ ] **`reset()`** clears all bubbles and resets `secondsUntilNextSpawn` to 0.

Run:
```bash
flutter test test/features/games/bubble_pop/bubble_notifier_test.dart
```
Expected: compilation error initially (notifier doesn't exist yet).

---

## Task 3: BubbleNotifier implementation

**Files:** create `lib/features/games/bubble_pop/bubble_notifier.dart`.

Sketch:

```dart
class BubbleNotifier extends Notifier<BubblePopState> {
  BubbleNotifier({Random? random}) : _random = random ?? Random();

  final Random _random;
  int _nextId = 0;

  @override
  BubblePopState build() => const BubblePopState();

  void tick(double dt, Size canvasSize) {
    // 1. advance positions
    final moved = <Bubble>[];
    for (final b in state.bubbles) {
      final newY = b.position.dy - b.velocityY * dt;
      if (newY + b.radius < -20) continue; // drop off-screen
      moved.add(b.copyWith(position: Offset(b.position.dx, newY)));
    }

    // 2. spawn scheduling
    var remaining = state.secondsUntilNextSpawn - dt;
    var list = moved;
    if (remaining <= 0 && list.length < _maxBubbles) {
      list = [...list, _spawnBubble(canvasSize)];
      remaining = _drawSpawnInterval();
    } else if (remaining <= 0) {
      // capped — try again next frame
      remaining = 0;
    }
    state = state.copyWith(bubbles: list, secondsUntilNextSpawn: remaining);
  }

  void spawn(Size canvasSize) {
    if (state.bubbles.length >= _maxBubbles) return;
    state = state.copyWith(bubbles: [...state.bubbles, _spawnBubble(canvasSize)]);
  }

  void pop(int id) {
    state = state.copyWith(
      bubbles: state.bubbles.where((b) => b.id != id).toList(growable: false),
    );
  }

  void reset() => state = const BubblePopState();

  Bubble _spawnBubble(Size size) { /* draw radius, color, velocity, x */ }
  double _drawSpawnInterval() => 0.4 + _random.nextDouble() * 0.7;

  static const _maxBubbles = 24;
}

final bubbleProvider =
    NotifierProvider<BubbleNotifier, BubblePopState>(BubbleNotifier.new);
```

Run tests, fix until green:
```bash
flutter test test/features/games/bubble_pop/bubble_notifier_test.dart
flutter analyze lib/features/games/bubble_pop/
```
Expected: all tests pass, no analyzer issues.

Commit:
```
feat: add BubbleNotifier with deterministic spawn + tick + pop
```

---

## Task 4: BubbleView widget

**Files:** create `lib/features/games/bubble_pop/bubble_view.dart`.

A `StatelessWidget` that takes a `Bubble` and an `onTap`. Renders a `Positioned` with `left = position.dx - radius`, `top = position.dy - radius`, `width/height = radius * 2`. Inside is a `GestureDetector(onTap: onTap)` wrapping a `CustomPaint` that draws:
- A filled circle with the bubble's color at 70% alpha (so layered bubbles still read).
- A 2-px white outline ring at full alpha.
- A small white highlight ellipse in the upper-left quadrant for that "bubble" look.

Acceptance: a tap anywhere in the bounding box invokes `onTap`. No `setState` in this widget — it is purely driven by props.

```bash
flutter analyze lib/features/games/bubble_pop/bubble_view.dart
```

---

## Task 5: BubblePopScreen — widget tests first

**Files:** create `test/features/games/bubble_pop/bubble_pop_screen_test.dart`.

Test setup mirrors `test/features/games/finger_paint/finger_paint_screen_test.dart`. Use `_makeContainer()` with the `audio_test_helper`'s `registerAudioFakes()` in `setUpAll`.

Cases:
- [ ] **Renders home button (home icon).**
- [ ] **When `bubbleProvider` is overridden with a notifier seeded with 3 bubbles, the screen renders 3 `BubbleView`s** (use a helper `_seedBubbles(container, [...])`).
- [ ] **Tapping a bubble removes it from state.** Find the BubbleView by predicate (e.g. inspect the painter's color), `tester.tap`, then read state and confirm length decreased.
- [ ] **No bubbles initially** (provider returns the default `BubblePopState`).

Run:
```bash
flutter test test/features/games/bubble_pop/bubble_pop_screen_test.dart
```
Expected: fails to compile (screen doesn't exist yet).

---

## Task 6: BubblePopScreen implementation

**Files:** create `lib/features/games/bubble_pop/bubble_pop_screen.dart`.

Sketch:

```dart
class BubblePopScreen extends ConsumerStatefulWidget {
  const BubblePopScreen({super.key});
  @override
  ConsumerState<BubblePopScreen> createState() => _BubblePopScreenState();
}

class _BubblePopScreenState extends ConsumerState<BubblePopScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    final size = MediaQuery.of(context).size;
    ref.read(bubbleProvider.notifier).tick(dt, size);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bubbles = ref.watch(bubbleProvider.select((s) => s.bubbles));
    final audio = ref.read(audioServiceProvider);
    final notifier = ref.read(bubbleProvider.notifier);
    return Scaffold(
      backgroundColor: DesignTokens.skyPeach,
      body: SafeArea(
        child: Stack(
          children: [
            for (final b in bubbles)
              BubbleView(
                key: ValueKey(b.id),
                bubble: b,
                onTap: () {
                  notifier.pop(b.id);
                  unawaited(audio.playSfx('bubble_pop'));
                },
              ),
            Positioned(
              top: DesignTokens.space2,
              left: DesignTokens.space2,
              child: _CircleOverlayButton(
                onTap: () => context.go('/'),
                child: const Icon(Icons.home_rounded, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

Run tests, analyze, format. Commit:
```
feat: add BubblePopScreen with Ticker-driven bubble motion
```

---

## Task 7: Router wiring

**Files:** modify `lib/core/routing/router.dart`.

Add import:
```dart
import 'package:toddler_games/features/games/bubble_pop/bubble_pop_screen.dart';
```

Replace the `/game/:id` builder body with:
```dart
final id = state.pathParameters['id']!;
if (id == 'finger_paint') return const FingerPaintScreen();
if (id == 'bubble_pop') return const BubblePopScreen();
return PlaceholderGameScreen(gameId: id);
```

Verify:
```bash
flutter analyze lib/core/routing/router.dart
flutter test test/app/view/shell_flow_test.dart
```

Commit:
```
feat: wire /game/bubble_pop route to BubblePopScreen
```

---

## Task 8: Full verification

```bash
flutter test --exclude-tags golden
flutter analyze
dart format --set-exit-if-changed lib/ test/
dart run custom_lint
```

All four must pass. Fix `dart format` issues with `dart format lib/ test/` and re-commit if needed.

---

## Task 9: Golden tests for BubblePopScreen

**Files:** modify `test/golden/golden_test.dart`; new `test/golden/goldens/bubble_pop_en.png`, `bubble_pop_ar.png`.

Add an import and a `BubblePopScreen` group at the end of `main()`. Override `bubbleProvider` with a notifier seeded with a **fixed list of 3 bubbles** at known positions, so the golden image is deterministic. To do this, expose a `BubbleNotifier.seeded(List<Bubble> initial)` factory, or override the provider with `bubbleProvider.overrideWith(() => _SeededBubbleNotifier(...))`.

Run goldens:
```bash
flutter test test/golden/golden_test.dart --tags golden --update-goldens
flutter test test/golden/golden_test.dart --tags golden
```

Commit:
```
test: add BubblePopScreen golden tests for en and ar locales
```

---

## Task 10: Tag + roadmap update

- [ ] **Final test sweep:** `flutter test` (all tags). All pass.
- [ ] **Tag the slice:** `git tag slice-3-complete`.
- [ ] **Update `docs/superpowers/ROADMAP.md`:** flip Slice 3 row to **Complete (tag: `slice-3-complete`)**, link this plan, update the "Next action" paragraph to point to Slice 4 (Shape Sorter).
- [ ] **Commit:** `docs: mark slice-3 bubble-pop complete in roadmap`.

---

## Audio asset note

The single SFX key used in this slice — `bubble_pop` — has no corresponding file in `assets/audio/sfx/`. As with Slice 2, `AudioService.playSfx` silently swallows missing-file errors, so the game is fully playable without sound. When a real `bubble_pop.mp3` is dropped into `assets/audio/sfx/`, it will be picked up with no code change.

A future polish pass can add `bubble_spawn` (very low-volume ambient burble) and a brief sparkle particle on pop. Both are non-blocking.

---

## Self-review checklist

| Spec requirement | Covered by task |
|---|---|
| Bubbles drift up at varied speed + size | Task 3 (`_spawnBubble` randomizes radius/velocity) |
| Tap to pop with SFX | Task 6 (`onTap` calls `pop` + `playSfx('bubble_pop')`) |
| Continuous spawn | Task 3 (`tick` schedules `_drawSpawnInterval()` each spawn) |
| No fail state | No "wrong" branches anywhere; missed taps are ignored |
| No score / clock | No state holds either |
| Stack + per-widget hit testing | Task 6 (`Stack` of `Positioned` `BubbleView`s) |
| Up to ~30 bubbles cap | Task 3 (`_maxBubbles = 24`) |
| Home button overlay | Task 6 (top-left `_CircleOverlayButton`) |
| Unit tests for state logic | Task 2 |
| Widget tests for screen | Task 5 |
| Golden tests in en + ar | Task 9 |
| No text the toddler reads | Bubbles are visual only |
| `very_good_analysis` lint clean | Task 8 |
