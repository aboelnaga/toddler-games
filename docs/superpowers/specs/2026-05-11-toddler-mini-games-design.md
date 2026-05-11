# Toddler Mini-Games App — Design Spec

**Date:** 2026-05-11
**Author:** Mohamed Aboelnaga
**Status:** Approved (pre-implementation)

---

## 1. Overview & Vision

A bilingual (Egyptian Arabic + English), fully offline, zero-data-collection mobile app for iOS and Android, containing five simple touch-based mini-games designed for children aged 2+. Built primarily for the author's son, but designed and licensed to publish under Apple's Kids Category and Google Play's Designed for Families program.

**Design pillars:**

- **Safe by construction** — no ads, no analytics, no network calls, no user accounts, no data collection. Compliance posture so simple the privacy policy fits on a postcard.
- **Toddler-first interaction** — no fail states, no timers, no text the kid is expected to read, big tap targets, forgiving gestures, positive feedback on every action.
- **Warm parent-child co-play** — the app rewards being looked at together; vocal celebrations and animal sounds make a parent want to repeat them with the child.
- **Architectural humility** — start with the smallest framework that does the job; keep each game self-contained so individual pieces can be upgraded later without cascading changes.

## 2. Audience & Success Criteria

**Primary user:** a child aged ~2.0 to 3.5. Pre-literate, motor skills include single-tap and basic drag, attention span 3–10 minutes per session, will tap rapidly and explore by mashing.

**Primary co-user:** a parent who plays alongside, names what they see, repeats words in either language.

**Success criteria for v1:**

1. The author's son plays it voluntarily and returns to it across days (the only test that really matters).
2. App passes Apple Kids Category and Google Play Designed for Families review on first or second submission.
3. Privacy policy is true: zero data leaves the device.
4. No crash on common 2–4 year old devices (iPad mini 4+, low-end Android with 2GB RAM running Android 9+).
5. App can be re-skinned or extended with a new game without touching unrelated game code.

## 3. Game Lineup (v1)

All five games share toddler design rules: no text the kid must read, no fail state, no timer, big tap targets (≥60dp), positive feedback on every touch, return-home affordance always visible.

### 3.1 Tap-to-Discover Zoo

A scene with 6 friendly animals. Tap any animal → it animates (bounce/scale), plays its sound, the spoken name is heard in the active language, and a small text label appears for parent reading. Ambient background sound layer: birds, gentle wind, light human chatter, food-truck atmosphere. No goal, no progression.

Skill: cause-and-effect, animal/sound association.

### 3.2 Bubble Pop

Colored bubbles drift up the screen at varied speeds and sizes. Tap a bubble → it pops with a sound effect and a sparkle particle. No fail state. Continuous spawn. Optional future "pop the red ones" mode is out of v1 scope.

Skill: hand-eye coordination, color awareness.

### 3.3 Shape Sorter

Three shapes (star, circle, triangle) sit at the bottom; three matching holes at the top. Kid drags a shape toward a hole. Snap-to-target with generous (~80dp) snap radius. Correct placement → cheer + sparkle. Wrong placement → shape gently bounces back, no scolding. Shapes regenerate after each round.

Skill: shape recognition, fine motor.

### 3.4 Finger Paint

Full-screen canvas with a color palette strip. Kid touches and drags → trail of color follows the finger. Optional "magic" mode: sparkle and small icons (stars, hearts, flowers) trail behind. A clear-canvas button (with a "Clear?" parent-gate-lite confirmation: hold the button for 2 seconds so accidental taps don't wipe a 5-minute creation).

Skill: motor control, creativity, color exploration.

### 3.5 Drive the Vehicle

A vehicle (car, truck, or train; v1 ships one) drags along a curved road/track painted across the screen. The vehicle is the draggable element; it stays glued to the path regardless of drag direction. Animals waving from the side animate as the vehicle passes them. Honk button in the corner.

Skill: tracing, motor control.

## 4. Art Direction

**Style:** hybrid — saturated chunky kindchenschema characters (oversized round heads, big eyes, no outlines on the character) on soft warm watercolor backdrops. Reference exemplars: Sago Mini, Hey Duggee.

**Three governing principles** (research-derived: Saiegh-Haddad on Arabic diglossia for language, Glocker on kindchenschema, Frontiers on play-area complexity, Toca Boca's stated design rules):

1. **Kindchenschema characters** — oversized round heads, big eyes with catchlights, chunky bodies, no realistic proportions.
2. **Saturated focal element on calm backdrop** — characters pop in bold color, backgrounds stay soft. Contrast carries attention.
3. **One action on screen, low scene complexity** — no clutter, no decorative text, no timers.

**Color palette (initial):**
- Character primary: warm orange `#ff8c42`
- Character cream: `#fff5e6`
- Sky peach: `#ffe1c0`
- Meadow green: `#a8d895`
- Accent pink blush: `#ff6b9d`
- Palette is capped at ~6 colors per scene to keep visual rhythm.

**To avoid:** outlines on the character, busy backgrounds, low-contrast pastel-only execution, realistic proportions, photorealism, scary features, decorative text.

**Generation pipeline:** Nano Banana (Gemini 2.5 Flash Image) via Google AI Studio for the master mascot fox + style-bible reference scenes. Once locked, a Python batch script uses the Gemini API to generate the rest of the assets, all referencing the style-bible images for cross-asset consistency. Master prompt and reference images are committed to `art/style-bible/` and are NOT bundled into the app — only optimized derivatives are.

## 5. Audio Direction

**Project-wide constraint:** No instrumental music anywhere — no background music tracks, no melodic celebration jingles, no instrument-pad mechanics. (Reason: project owner's faith preference; codified in shared memory.)

**Audio elements in scope:**
- **Sound effects** — pop, whoosh, sparkle, vroom, splash, animal noises
- **Spoken voice narration** — animal names, friendly cues, gentle instructions in the active locale
- **Nature & ambient backgrounds** — birds chirping, light wind, water trickling, leaves rustling, human chatter, food-truck atmosphere in Zoo
- **Vocal-only celebrations** — a cappella "yay!", clapping, child laughter on success

**Audio architecture:**
- Single `AudioService` singleton wraps `audioplayers`. Three independent channels: `voice`, `sfx`, `ambience`. Each respects a master mute toggle.
- SFX and ambience clips are locale-agnostic; voice clips are locale-namespaced.
- File layout: `assets/audio/sfx/`, `assets/audio/ambience/`, `assets/audio/voice/{locale}/`.
- Voice clips named by stable semantic key (e.g., `animal_cow.mp3`, `cheer_yay.mp3`, `count_one.mp3`).

## 6. Localization & Language

**Locales shipped in v1:** `ar-EG` (Egyptian Arabic, default) and `en` (English).

**Why Egyptian, not MSA:** MSA is no one's L1; it is acquired later through reading and schooling. For a 2-year-old, the child's home dialect is his actual language. Egyptian also has the broadest pan-Arab spoken reach due to regional media dominance. MSA layer is reserved for v2 (for letters/numbers/classic vocabulary).

**Why not English-primary:** English will reach the child through the rest of the environment regardless. The variable the family controls is the Arabic input. Bilingual-development research is unambiguous here.

**Locale handling:**
- App launches in `ar-EG` by default.
- UI text is stored in `.arb` files (`l10n/intl_en.arb`, `l10n/intl_ar_EG.arb`) via `flutter_intl`. Kid-facing screens have essentially no text; parent-facing screens require full RTL support.
- Numbers in the counting context use Egyptian colloquial forms (واحد، اتنين، تلاتة), not MSA forms (واحد، اثنان، ثلاثة).
- Parent-gate math problem uses Arabic-Indic numerals (٠–٩) when Arabic is active.
- The locale system is N-ready: adding a third locale (MSA, French, etc.) must require only adding an `.arb` file and a voice asset folder. Do not hard-code "two locales" anywhere.

## 7. App Shell

### 7.1 Home screen

- 2×3 icon grid. Top two rows show the 5 game tiles (positions 1–5). Slot 6 is reserved for future game.
- Each tile is a large, color-coded card with the game's mascot/icon centered. Tap → enter game.
- Bottom-left corner: a small fox mascot icon (return-home; only visible when inside a game, not on the home screen itself).
- Bottom-right corner: a gear icon (opens parent gate → settings).

### 7.2 Parent gate

- Triggered by gear icon, by clear-canvas-in-finger-paint hold (a softer hold-based confirmation; same gate not required for clearing the canvas), by any external-link tap.
- Style: single-digit addition (e.g., `7 + 3 = ?`), four multiple-choice numeric buttons. New problem on each gate invocation; on wrong answer, generate a fresh problem (do not just shake — avoid random-tap success).
- Numerals localized: Arabic-Indic when `ar-EG` is active, Western when `en` is active.
- Visual treatment: warm "For Grown-Ups / لأولياء الأمور" header, friendly card background, but no animation/sparkle (keep the gate clinical enough to discourage toddler exploration).

### 7.3 Settings (parent-only, behind gate)

Contents:
1. **Language toggle** — Egyptian Arabic ↔ English, with a small flag preview.
2. **Sound master toggle** — on/off.
3. **Per-game enable/disable** — five toggles, one per game. Disabled games render as dimmed slots on the home screen; tap is a no-op or shows a small lock icon.
4. **About** — app version, support email (mailto: link, no parent-gate needed), privacy policy link (opens external webview behind a second parent-gate confirmation), terms link (same).

Out of scope for v1 settings: session timer (OS handles this better), reset progress (no progress to reset), restore purchases (no IAP).

## 8. Compliance & Privacy

**Posture:** zero data collection.

**Concrete constraints:**
- No third-party analytics (Firebase Analytics, Mixpanel, Amplitude, PostHog, etc.)
- No crash reporting that transmits off-device (Sentry, Crashlytics, Bugsnag). Local error logging only.
- No advertising SDKs.
- No user accounts, no cloud sync, no remote config, no push notifications.
- No `android.permission.INTERNET` on the release flavor's `AndroidManifest.xml`.
- No outbound network code anywhere in the app.
- iOS: ship an empty `PrivacyInfo.xcprivacy`. No networking entitlements. `NSAllowsArbitraryLoads=false`.

**Stated to stores:**
- App Privacy nutrition label (iOS): "No data collected."
- Data Safety form (Google Play): "No data collected, no data shared."
- Age declaration: Apple 0–5, Google "Ages 5 & Under."

**Privacy policy & terms:** hosted on GitHub Pages. Privacy policy literally states: "We do not collect, store, or transmit any data. This app works fully offline. Your child's interactions stay on your device."

**CI safety guards:**
- Build fails if `pubspec.lock` contains any of: `firebase_`, `sentry`, `mixpanel`, `amplitude`, `facebook_`, `appsflyer`.
- Build fails if `AndroidManifest.xml` for the release flavor contains `INTERNET` permission.
- PR template: every new dependency must declare its network behavior and transitive deps in the PR description.

**Pre-launch checklist (external):**
- Apple Developer Program account ($99/yr)
- Google Play Developer account ($25 one-time)
- Support email address (real, monitored)
- Privacy policy URL live and accessible
- Store screenshots prepared in Arabic and English
- Age-rating questionnaires completed (consistent: 4+ / Ages 5 & Under)

## 9. Architecture & Stack

### 9.1 Framework decisions

| Concern | Choice | Reason |
|---|---|---|
| UI framework | Flutter stable | One codebase iOS+Android; code-first (AI-friendly); strong asset/audio/animation primitives |
| Game engine | **None (pure Flutter widgets)** | All 5 games are widget-shaped (tap, drag, paint, drag-along-path). Flame buys nothing here. Door remains open per game later. |
| State management | Riverpod 2.x | Lower boilerplate than Bloc at this scale; codegen-friendly; matches `riverpod_lint` tooling |
| Routing | go_router + go_router_builder | Typed routes; deep-link-ready for future store campaigns |
| Localization | flutter_intl + .arb | Standard; covers RTL out-of-the-box |
| Audio | audioplayers | Maintained, no SDK risk, supports per-channel volume |
| Persistence | shared_preferences | Settings only — small, no schema migrations |
| Drawing | CustomPainter | Finger-paint canvas + vehicle path |
| Animation | AnimationController/Tween + flutter_animate sugar | Native, no third-party deps for core animation |

### 9.2 Why no Flame in v1

For each game, pure Flutter is either equal to or simpler than a Flame implementation:
- Zoo → `GestureDetector` + `AnimatedScale`
- Bubble Pop → `Stack` + `AnimatedPositioned` (up to ~30 bubbles is well within Flutter's render budget)
- Shape Sorter → `Draggable` / `DragTarget` (purpose-built)
- Finger Paint → `CustomPainter` + `GestureDetector`
- Drive Vehicle → `CustomPainter` (path) + `Draggable`

Flame becomes worthwhile only if a future game needs a 60fps game loop, dense collision detection, particle systems, or sprite-sheet character animation. Cost of adding it later for one new game: ~half a day. Cost of migrating one existing game to it: 1–2 days, contained.

### 9.3 Module boundaries

Each of the five games is a self-contained folder under `lib/features/games/{name}/` that exposes a single Widget. The home screen and routing layer do not know what is inside a game — only that it is a Widget. This is the cheapest possible interface to maintain and the friendliest possible boundary for future per-game migration to Flame.

Audio, locale, and settings live behind service interfaces (Riverpod providers) accessible from anywhere — including a future Flame game.

## 10. Project Bootstrap & Dev Tooling

### 10.1 Scaffold

`very_good create flutter_app -t core` (Very Good CLI). Then:
- Remove the Bloc dependencies from `pubspec.yaml`.
- Add `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`, `go_router`, `go_router_builder`.
- Layer Andrea Bizzotto's Riverpod-architecture conventions (feature folders with data/domain/presentation where applicable; thin services accessed via providers).

Why VGV Core: most actively maintained Flutter scaffold; ships flavors (dev/stg/prod), arb localization, multi-platform setup, test scaffolding, GH Actions templates. We replace its default state-mgmt and routing choices but keep the structural backbone.

### 10.2 Lint & static analysis

```yaml
dev_dependencies:
  very_good_analysis: ^9.0.0
  custom_lint: ^0.8.0
  riverpod_lint: ^2.6.5
```

`analysis_options.yaml` includes `package:very_good_analysis/analysis_options.yaml` and enables the `custom_lint` plugin. `flutter_lints` is removed.

### 10.3 Codegen

Day-one dependencies (all under `dev_dependencies` except annotations):
- `build_runner`
- `riverpod_generator` + `riverpod_annotation`
- `freezed` + `freezed_annotation`
- `json_serializable` (for serializing settings to shared_preferences when shape grows)
- `flutter_launcher_icons`, `flutter_native_splash`
- `go_router_builder`

Standing command: `dart run build_runner watch -d`. Use `dart pub upgrade --tighten` instead of unilateral version bumps to keep generators compatible.

### 10.4 CI & pre-commit hooks

- **Lefthook** for pre-commit and pre-push:
  - Pre-commit: `dart format --set-exit-if-changed` + `flutter analyze --fatal-infos` on staged files.
  - Pre-push: `flutter test` + `dart run custom_lint`.
- **GitHub Actions** with `subosito/flutter-action@v2`:
  - Matrix jobs: analyze, format-check, test (with coverage).
  - Golden tests run **only on macOS runners** (Linux font rendering drifts goldens). Tag with `flutter test --tags golden` and gate on a dedicated macOS job.
  - Forbidden-SDK grep job: fails if `pubspec.lock` contains any of `firebase_`, `sentry`, `mixpanel`, `amplitude`, `facebook_`, `appsflyer`.
  - INTERNET-permission grep job: fails if release flavor's `AndroidManifest.xml` contains `android.permission.INTERNET`.

### 10.5 AI assistant rules

Three files, two are symlinks:
- `CLAUDE.md` — canonical
- `AGENTS.md` → symlink to `CLAUDE.md` (Codex CLI convention)
- `.cursorrules` → symlink to `CLAUDE.md` (Cursor convention)

`CLAUDE.md` must contain at minimum:
- Stack summary and the no-network / no-analytics / no-Firebase / no-Sentry invariant
- Codegen commands (`dart run build_runner watch -d`)
- Riverpod conventions: prefer `@riverpod` generator over manual providers; standard `AsyncValue` patterns
- Routing: typed routes via `go_router_builder` (do not write string-based routes)
- Test layout convention: `test/` mirrors `lib/`
- arb workflow: never hand-edit generated `app_localizations.dart`
- Audio invariant: no instrumental music
- Bilingual invariant: Egyptian Arabic primary, English secondary; Arabic-Indic numerals when AR active
- Seed reference: Flutter's official [AI rules doc](https://docs.flutter.dev/ai/ai-rules)

## 11. Project Structure

```
lib/
  main.dart                     # entry point, locale bootstrap
  app.dart                      # MaterialApp.router + Riverpod scope

  core/
    audio/                      # AudioService (audioplayers wrapper)
    locale/                     # LocaleNotifier provider, locale persistence
    settings/                   # SettingsService (shared_preferences)
    gate/                       # ParentGate widget, math problem generator
    routing/                    # go_router config (typed routes)
    theme/                      # design tokens (colors, spacing, type, radii)

  features/
    home/                       # icon grid + game tiles
    settings/                   # settings screen (behind gate)
    games/
      zoo/
      bubble_pop/
      shape_sorter/
      finger_paint/
      drive_vehicle/

  l10n/
    intl_en.arb
    intl_ar_EG.arb

assets/
  images/
    ui/                         # shared icons, home tiles
    games/
      zoo/        bubble_pop/   shape_sorter/
      finger_paint/  drive_vehicle/
  audio/
    sfx/                        # locale-agnostic SFX
    ambience/                   # nature/atmosphere loops
    voice/
      ar-EG/                    # Egyptian Arabic
      en/                       # English

art/                            # source art, NOT bundled into the app
  style-bible/
    mascot-fox.png
    reference-scenes/
    master-prompt.md
    palette.md

docs/
  superpowers/specs/            # design docs (this file)

.github/workflows/              # CI
CLAUDE.md                       # canonical AI rules
AGENTS.md                       # symlink → CLAUDE.md
.cursorrules                    # symlink → CLAUDE.md
analysis_options.yaml
lefthook.yml
pubspec.yaml
```

## 12. Testing Strategy

- **Unit tests** (`flutter_test`):
  - Parent-gate math problem generator (correctness, no repeats in a session, randomized order)
  - Settings service (read/write/migration)
  - Locale switching logic
- **Widget tests:**
  - Home grid renders 5 tiles + 1 reserved slot
  - Parent gate accepts the correct answer and rejects wrong ones (regenerates problem)
  - Settings toggles persist
  - Each game's basic interaction (tap registers, drag completes, no crash)
- **Golden tests** (macOS runners only, tagged `golden`):
  - Home screen in `ar-EG` and `en` (catches RTL regressions)
  - Parent gate in `ar-EG` and `en`
  - Settings screen in `ar-EG` and `en`
- **Manual playtesting:**
  - With the author's son. Iterate on what he gravitates to and what he ignores.
  - On a low-end Android (e.g., a 2GB-RAM device or emulator) to confirm Bubble Pop's stack-of-bubbles doesn't stutter.

Coverage target is not a number; coverage target is "no kid-facing path is untested."

## 13. Out of Scope (v2+)

- MSA voice layer (formal Arabic for letters/numbers/classic vocabulary)
- Hub-world home screen (illustrated meadow with tappable hotspots; expensive)
- Additional games: Memory Match, Peek-a-boo, Counting 1–5, Sticker / Dress-Up, Chunky Puzzles
- Flame migration (only triggered by a specific game outgrowing widgets)
- Cloud-synced parental dashboard, progress, or analytics
- Multiplayer or co-play
- Customizable mascot (kid picks species/color)
- In-app purchases for unlocking content
- Tablet-specific layouts beyond responsive default

## 14. Open Questions & Risks

- **Voice talent:** human recording vs ElevenLabs AI. Need to A/B a sample of Egyptian child-friendly voices before committing. Falls into implementation, not design.
- **Asset bundle size:** five illustrated games with bundled voice (two locales) plus ambient audio could push the binary above 50MB. Need to budget asset weight during implementation (target: <60MB iOS, <50MB Android APK). Mitigations available: WebP for images, OGG for audio, deferred per-game asset loading.
- **iOS PrivacyInfo.xcprivacy schema:** Apple may update the manifest schema before launch; track changes to required reason API declarations.
- **Apple Kids Category review timing:** historically 1–2 weeks longer than standard review. Plan first submission to allow buffer.
- **Drive-the-Vehicle path correctness:** path-following math (constraining a draggable to a Bezier curve) is the most complex single piece of game code; allocate extra implementation time and write unit tests for the path projector function.
- **Finger-paint memory growth:** long sessions could accumulate enough stroke points to slow rendering. Implementation should checkpoint to a bitmap layer after N strokes.
- **Developer accounts:** author does not yet hold Apple or Google Play developer accounts; factor account-setup into the launch timeline.

---

*End of design spec. The next artifact is an implementation plan, produced via the writing-plans skill.*
