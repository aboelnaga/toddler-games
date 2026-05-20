# Shape Sorter Game (Slice 4) Implementation Plan

> Medium-depth plan, matching Slice 3 conventions. Each task lists files, design intent, and verification commands.

**Goal:** Build the Shape Sorter mini-game end-to-end. Three shapes (circle, star, triangle) sit in the lower half; three matching holes sit in the upper half. The child drags a shape; on near-miss to the matching hole it snaps into place. Wrong drop → gentle bounce back, no scolding. After all three are placed, a celebration plays and a fresh round begins.

**Architecture:**
- `lib/features/games/shape_sorter/` — self-contained feature folder.
- `models/shape_kind.dart` — `enum ShapeKind { circle, star, triangle }` (with a deterministic order for layout).
- `models/shape_sorter_state.dart` — `ShapeSorterState(placed, roundId)` where `placed` is a `Set<ShapeKind>` of holes that have been filled this round.
- `shape_sorter_notifier.dart` — `ShapeSorterNotifier extends Notifier<ShapeSorterState>` with `place(ShapeKind)`, `nextRound()`, and a `bool isComplete` getter derived from `placed.length == 3`. On completion, schedule a delayed reset via the screen (the notifier itself is timing-agnostic — the screen owns the delay so tests don't need real timers).
- `shape_painter.dart` — `CustomPainter` that draws any `ShapeKind` either filled (draggable) or outlined (hole), sized to a target rect.
- `draggable_shape.dart` — wraps `Draggable<ShapeKind>` showing the shape as both the resting child and the drag feedback. Uses a `dragAnchorStrategy` so the shape lifts from its centre.
- `shape_hole.dart` — wraps `DragTarget<ShapeKind>` showing the outlined hole. `onWillAcceptWithDetails` returns true only when the dragged kind matches the hole's kind; rejection means Draggable runs its built-in spring-back animation (free for us).
- `shape_sorter_screen.dart` — root layout: 3 holes in a top row, 3 shapes in a bottom row, home button overlay, and a transient celebration overlay when `placed.length == 3`.

**Tech stack:** Flutter stable / Dart 3.x · Riverpod 3 · go_router 17 · `Draggable` / `DragTarget` (built-in spring-back, hit-testing free) · `CustomPainter` for shape geometry · existing `AudioService`.

**Companion docs:**
- [Product Requirements §4.3](../specs/2026-05-11-toddler-mini-games-prd.md)
- [Technical Design Spec §3.3, §9.2](../specs/2026-05-11-toddler-mini-games-design.md)
- [Slice 3 plan (precedent for game-feature layout)](./2026-05-20-slice-3-bubble-pop.md)

**Pre-conditions:** Slices 0–3 complete. `slice-3-complete` tag present. Home tile + settings already include `shape_sorter`. Router currently routes `/game/shape_sorter` to the placeholder.

---

## Hard invariants (copy from CLAUDE.md — never violate)

1. No network calls, no analytics SDKs.
2. No instrumental music. SFX + voice + vocal cheer OK.
3. No fail states. Wrong drop = gentle bounce back; **never** a scolding sound, red X, or "wrong" indicator.
4. No in-game text the toddler must read.
5. Bilingual: ar-EG primary, en secondary. The screen has no text in v1; voice/cheer is locale-aware via `AudioService.playVoice`.

---

## Why `Draggable` over `Listener`/manual hit-testing

`Draggable` + `DragTarget` give us four behaviours for free that we'd otherwise need to hand-code:
1. **Lift-and-follow gesture** with pixel-accurate offset.
2. **Spring-back animation** on a rejected drop (~`Draggable.feedback` returning to origin).
3. **Hit-testing** based on `DragTarget` bounds (we set generous bounds for the ~80dp snap).
4. **Accept/reject visual hooks** via `onWillAcceptWithDetails`.

The "near-miss snap" from the design spec is implemented by sizing each `DragTarget` larger than the hole's visible footprint — generous bounds = generous snap.

---

## File structure

```
lib/features/games/shape_sorter/
  models/
    shape_kind.dart                # CREATE — enum + ordered list
    shape_sorter_state.dart        # CREATE — immutable state
  shape_painter.dart               # CREATE — CustomPainter for all 3 shapes
  shape_hole.dart                  # CREATE — DragTarget wrapper
  draggable_shape.dart             # CREATE — Draggable wrapper
  shape_sorter_notifier.dart       # CREATE — Notifier + provider
  shape_sorter_screen.dart         # CREATE — root screen

lib/core/routing/router.dart       # MODIFY — add shape_sorter branch

test/features/games/shape_sorter/
  shape_sorter_notifier_test.dart  # CREATE
  shape_sorter_screen_test.dart    # CREATE

test/golden/
  golden_test.dart                 # MODIFY — add ShapeSorterScreen group
  goldens/
    shape_sorter_en.png            # generated on first run
    shape_sorter_ar.png            # generated on first run
```

---

## Visual design constants

Locked here so tests stay stable. Live as `static const` on a private config or as top-level `const`s in `shape_sorter_screen.dart`:

- Shape side length (draggable footprint): 100 dp.
- Hole side length (outlined target footprint): 110 dp (slightly larger → generous snap).
- Shape colors:
  - Circle → `Color(0xFFE53935)` (red).
  - Star → `Color(0xFFFDD835)` (yellow).
  - Triangle → `Color(0xFF1E88E5)` (blue).
- Background: `DesignTokens.cream` for warmth.
- Outline stroke width for holes: 4 dp, color `DesignTokens.textCharcoal` at 25% alpha.
- Round-complete celebration: brief Sparkle overlay (re-use a simple `AnimatedOpacity` + Material `Icons.celebration_rounded`), fades out and a fresh round starts ~1.4s later.

Shape order in the row (left → right): `circle`, `star`, `triangle`. Same order top and bottom.

---

## Task 1: ShapeKind enum + ShapeSorterState

**Files:** `lib/features/games/shape_sorter/models/shape_kind.dart`, `.../shape_sorter_state.dart`.

Sketches:

```dart
// shape_kind.dart
enum ShapeKind { circle, star, triangle }

const kShapeOrder = [ShapeKind.circle, ShapeKind.star, ShapeKind.triangle];
```

```dart
// shape_sorter_state.dart
@immutable
class ShapeSorterState {
  const ShapeSorterState({this.placed = const {}, this.roundId = 0});
  final Set<ShapeKind> placed;
  final int roundId;
  bool get isComplete => placed.length == ShapeKind.values.length;
  ShapeSorterState copyWith({Set<ShapeKind>? placed, int? roundId});
}
```

Verify:
```bash
flutter analyze lib/features/games/shape_sorter/models/
```

---

## Task 2: ShapeSorterNotifier — tests first

**Files:** `test/features/games/shape_sorter/shape_sorter_notifier_test.dart`.

Cover:
- [ ] Initial state: `placed` empty, `roundId == 0`, `isComplete == false`.
- [ ] `place(ShapeKind.circle)` adds circle to `placed`.
- [ ] Placing the same kind twice is a no-op (set semantics).
- [ ] After placing all three, `isComplete == true`.
- [ ] `nextRound()` empties `placed` and increments `roundId`.

Run:
```bash
flutter test test/features/games/shape_sorter/shape_sorter_notifier_test.dart
```
Expect a compilation error initially.

---

## Task 3: ShapeSorterNotifier implementation

**Files:** `lib/features/games/shape_sorter/shape_sorter_notifier.dart`.

Sketch:

```dart
class ShapeSorterNotifier extends Notifier<ShapeSorterState> {
  @override
  ShapeSorterState build() => const ShapeSorterState();

  void place(ShapeKind kind) {
    if (state.placed.contains(kind)) return;
    state = state.copyWith(placed: {...state.placed, kind});
  }

  void nextRound() {
    state = ShapeSorterState(placed: const {}, roundId: state.roundId + 1);
  }
}

final shapeSorterProvider =
    NotifierProvider<ShapeSorterNotifier, ShapeSorterState>(
        ShapeSorterNotifier.new);
```

Run tests, then:
```bash
flutter analyze lib/features/games/shape_sorter/
```

---

## Task 4: ShapePainter

**Files:** `lib/features/games/shape_sorter/shape_painter.dart`.

A single `CustomPainter` taking `(ShapeKind kind, Color color, bool outlined)`. Drawn into the bounds it's given.

- Circle: `canvas.drawCircle(center, radius - inset, paint)`.
- Star: 5-pointed star via a `Path` with alternating outer/inner radii.
- Triangle: equilateral upward-pointing via 3-point `Path`.

When `outlined`, use `style = PaintingStyle.stroke` with 4 dp stroke; when filled, `PaintingStyle.fill`.

Visual smoke: render under a small widget test that pumps `CustomPaint(painter: ..., size: …)` and screenshots are deferred to the golden phase.

```bash
flutter analyze lib/features/games/shape_sorter/shape_painter.dart
```

---

## Task 5: DraggableShape + ShapeHole

**Files:** `lib/features/games/shape_sorter/draggable_shape.dart`, `.../shape_hole.dart`.

```dart
// draggable_shape.dart
class DraggableShape extends StatelessWidget {
  const DraggableShape({required this.kind, required this.color, super.key});
  final ShapeKind kind;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final art = SizedBox(
      width: kShapeSize,
      height: kShapeSize,
      child: CustomPaint(painter: ShapePainter(kind: kind, color: color)),
    );
    return Draggable<ShapeKind>(
      data: kind,
      feedback: Material(color: Colors.transparent, child: art),
      childWhenDragging: const SizedBox(width: kShapeSize, height: kShapeSize),
      child: art,
    );
  }
}
```

```dart
// shape_hole.dart
class ShapeHole extends StatelessWidget {
  const ShapeHole({required this.kind, required this.filled, super.key});
  final ShapeKind kind;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return DragTarget<ShapeKind>(
      onWillAcceptWithDetails: (d) => !filled && d.data == kind,
      onAcceptWithDetails: (d) => /* delegated up via callback */,
      builder: (context, _, __) => SizedBox(
        width: kHoleSize,
        height: kHoleSize,
        child: CustomPaint(
          painter: ShapePainter(
            kind: kind,
            color: filled ? kFilledColors[kind]! : Colors.black26,
            outlined: !filled,
          ),
        ),
      ),
    );
  }
}
```

Both widgets should expose `onAccept` callbacks rather than reaching into Riverpod directly — keeps them testable in isolation. The screen wires them to the notifier.

```bash
flutter analyze lib/features/games/shape_sorter/
```

---

## Task 6: ShapeSorterScreen

**Files:** `lib/features/games/shape_sorter/shape_sorter_screen.dart`.

Layout sketch (ASCII):

```
+--------------------------------------------------+
| [home]                                           |
|                                                  |
|        O          ☆          △                   |   <- 3 holes (top)
|       /circle    /star      /triangle            |
|                                                  |
|                                                  |
|        O          ☆          △                   |   <- 3 draggables (bottom)
|                                                  |
+--------------------------------------------------+
```

On `onAcceptWithDetails` for a hole, the screen calls `notifier.place(kind)` and `audio.playSfx('shape_snap')`. When `state.isComplete`, it shows a `Positioned.fill` celebration overlay (fox/sparkle icon + `playVoice('cheer_yay', locale)`), waits ~1.4s, then calls `notifier.nextRound()`.

The shape that has been placed disappears from the bottom row (Riverpod-driven: only render shapes whose kind is not in `state.placed`). This is the "shape regenerates after round" mechanic — when nextRound() runs, `placed` empties and the three shapes reappear.

Use `Wrap` or a fixed `Row` with `MainAxisAlignment.spaceEvenly` for the two rows.

Verification:
```bash
flutter analyze lib/features/games/shape_sorter/
```

---

## Task 7: Router wiring

**Files:** `lib/core/routing/router.dart`.

Add import:
```dart
import 'package:toddler_games/features/games/shape_sorter/shape_sorter_screen.dart';
```

Add branch:
```dart
if (id == 'shape_sorter') return const ShapeSorterScreen();
```

Verify:
```bash
flutter analyze lib/core/routing/router.dart
flutter test test/app/view/shell_flow_test.dart
```

---

## Task 8: Widget + golden tests

**Files:** `test/features/games/shape_sorter/shape_sorter_screen_test.dart`, `test/golden/golden_test.dart`.

Widget tests:
- Renders 3 `ShapeHole`s (top row).
- Renders 3 `DraggableShape`s (initial state).
- `notifier.place(circle)` → only star + triangle draggables remain on screen.
- After all 3 placed, celebration overlay appears.

Drag-and-drop integration is awkward to simulate in widget tests because of Flutter's `Draggable` long-press recognition. Instead, drive the notifier directly and assert on the rendered tree — that's where the user-visible behaviour lives.

Golden tests: as in Slice 3, override the provider with a frozen state (e.g., `placed: { circle }`) so the snapshot is deterministic. Generate en + ar variants.

```bash
flutter test --exclude-tags golden
flutter test test/golden/golden_test.dart --tags golden --update-goldens
flutter test test/golden/golden_test.dart --tags golden
```

---

## Task 9: Verify, roadmap, tag

```bash
flutter analyze
dart format --set-exit-if-changed lib/ test/
dart run custom_lint
flutter test
```

All must pass.

Then:
- Update `docs/superpowers/ROADMAP.md`: flip Slice 4 row to **Complete (tag: `slice-4-complete`)** with link to this plan; update "Next action" to Slice 5 (Tap-to-Discover Zoo).
- `git tag slice-4-complete`.
- Commit messages: one feat commit for the feature folder + router, one test commit for goldens, one docs commit for the roadmap.

---

## Audio asset note

The two SFX/voice keys used in this slice (`shape_snap` and `cheer_yay`) have no corresponding files in `assets/audio/`. As before, `AudioService` silently swallows missing-file errors so the game is fully playable without sound; drop matching `.mp3` files in later for instant pickup.

---

## Self-review checklist

| Spec requirement | Covered by task |
|---|---|
| 3 shapes: circle, star, triangle | Task 1, 4 |
| 3 matching holes | Task 5 |
| Drag-to-snap with ~80dp snap | Task 5 (`DragTarget` size = 110dp vs shape 100dp) |
| Wrong drop bounces back | Task 5 (`onWillAcceptWithDetails` returns false; Draggable's built-in spring back) |
| No fail state | Task 5 (no scolding sound, no error UI) |
| Correct drop → cheer + sparkle | Task 6 (overlay + `playVoice('cheer_yay')`) |
| Shapes regenerate each round | Task 6 (`nextRound()` clears `placed`) |
| Home button overlay | Task 6 |
| Notifier unit tests | Task 2 |
| Widget tests | Task 8 |
| Golden tests en + ar | Task 8 |
| Lint clean | Task 9 |
| No text the toddler reads | Task 6 (icons + shapes only) |
| No network calls | AudioService uses `AssetSource` only |
