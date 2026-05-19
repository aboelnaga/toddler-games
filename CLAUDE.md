# Project Conventions for AI Assistants

This file is read automatically by Claude Code (and by Codex CLI / Cursor via the symlinked `AGENTS.md` / `.cursorrules`).

## What this project is

A bilingual (Egyptian Arabic primary, English secondary) Flutter app of five touch-based mini-games for 2-year-olds, published to Apple Kids Category and Google Play Designed for Families. Fully offline, zero data collection.

See `docs/superpowers/specs/2026-05-11-toddler-mini-games-prd.md` for the product story and `docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md` for the technical design.

## Hard invariants — DO NOT VIOLATE

These are project values, not preferences. Violating any of these requires explicit user approval and a memo in the spec.

1. **No network calls.** The app does not make HTTP requests, does not talk to any server, does not load remote assets. The `INTERNET` permission is stripped from the release Android flavor. iOS `PrivacyInfo.xcprivacy` declares no network activity.
2. **No third-party analytics, crash reporting, or ads.** No Firebase, Sentry, Crashlytics, Mixpanel, Amplitude, PostHog, Facebook SDK, AppsFlyer, etc.
3. **No instrumental music.** Animal sounds, sound effects, nature ambience, and spoken voice are fine. Background music, melodic jingles, instrument-pad mechanics are not.
4. **No fail states in any game.** No red X, no scolding sound, no "wrong" feedback. Mistakes simply do not register.
5. **Bilingual: Egyptian Arabic primary, English secondary.** Egyptian (مصري) dialect, not MSA. Use Egyptian colloquial numbers (واحد، اتنين، تلاتة) not MSA forms.
6. **No text the toddler is expected to read in-game.** Parent-facing screens (settings, parent gate, about) can have text. Game scenes use icons and voice.

## Tech stack — current

- Flutter stable, Dart 3
- State: Riverpod 3.x (prefer `@riverpod` generator)
- Routing: go_router 17.x (typed routes via go_router_builder when feasible)
- Localization: gen-l10n with `.arb` files in `lib/l10n/arb/`, generated into `lib/l10n/gen/`
- Audio: `audioplayers` (to be added in Slice 1/2)
- Local storage: `shared_preferences`
- Drawing: `CustomPainter`
- Game engine: **none** — pure Flutter widgets. Do not add Flame unless explicitly approved.

## Code style & conventions

- Lint config: `very_good_analysis` + `custom_lint` + `riverpod_lint`. Run `flutter analyze` AND `dart run custom_lint` before claiming work is done.
- Format: `dart format` (run automatically via pre-commit hook).
- Naming: file names are `snake_case.dart`. Public types are `UpperCamelCase`. Private/library-internal types are prefixed with `_`.
- Test layout: `test/` mirrors `lib/`. A file `lib/foo/bar.dart` has its test at `test/foo/bar_test.dart`.
- Prefer the `@riverpod` codegen syntax over manual `Provider`/`StateNotifierProvider` declarations.
- Prefer immutable models via `freezed` 3.x. Note: Freezed 3 requires `abstract class` syntax (`@freezed abstract class Foo with _$Foo { ... }`).

## Codegen

Standing command (run in a separate terminal during dev):

```bash
dart run build_runner watch -d
```

Or one-shot:

```bash
dart run build_runner build --delete-conflicting-outputs
```

After adding a `@riverpod`, `@freezed`, or `@JsonSerializable` annotation, run codegen before continuing.

## Routing

Use the `routerProvider` in `lib/core/routing/router.dart`. Add new routes there. Prefer named navigation (`router.go('/settings')`) over string literals scattered across the code.

When `go_router_builder` is wired up (later in Slice 1+), use typed routes — do **not** write raw string paths in widget code.

## Localization

- All user-visible strings (parent-facing) go in `.arb` files.
- Never hand-edit the generated `app_localizations*.dart` — it's regenerated on every build.
- New string keys: add to `app_en.arb` first (template), then `app_ar.arb`. Both files must stay in sync.
- For voice clips (kid-facing audio), use stable semantic keys like `cheer_yay`, `animal_cow`, `count_one`. Audio file lookup is locale-aware: `assets/audio/voice/{locale}/{key}.mp3`.

## Testing

- Unit tests for pure logic (parent-gate math generator, settings service, locale provider).
- Widget tests for every screen and game.
- Golden tests for home + parent gate + settings in both locales (catch RTL regressions). Golden tests run on **macOS runners only** in CI.
- Tag golden tests `@Tags(['golden'])` and run them with `flutter test --tags golden`.

## What NOT to do

- Do not add Firebase, Sentry, or any analytics package. Do not add `flutter_bloc` (we're on Riverpod). Do not add Flame unless explicitly approved.
- Do not hand-edit `*.g.dart`, `*.freezed.dart`, or generated `app_localizations*.dart`.
- Do not add string-based GoRouter paths in widget code (once go_router_builder is wired).
- Do not commit `.lefthook-local.yml` or `.env*` files.
- Do not add `android.permission.INTERNET` to any AndroidManifest. The CI compliance job will fail the build.
- Do not bundle source style-bible images from `art/` — only optimized derivatives belong in `assets/`.

## Reference

- Flutter docs: https://docs.flutter.dev
- Flutter AI rules (seed for this file): https://docs.flutter.dev/ai/ai-rules
- Riverpod: https://riverpod.dev
- go_router: https://pub.dev/packages/go_router
