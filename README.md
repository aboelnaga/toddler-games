# Toddler Mini-Games

Bilingual (Egyptian Arabic + English), fully offline, zero-data-collection mini-games for children aged 2+.

- [Product Requirements](docs/superpowers/specs/2026-05-11-toddler-mini-games-prd.md)
- [Design Spec](docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md)
- [Roadmap & current status](docs/superpowers/ROADMAP.md)
- [AI assistant rules](CLAUDE.md)

## Prerequisites

- Flutter stable (3.x+), Dart 3.x+
- iOS: Xcode + CocoaPods (`sudo gem install cocoapods`)
- Android: Android Studio + Android SDK
- `lefthook` for git hooks: `brew install lefthook`
- `very_good_cli` (already used to scaffold): `dart pub global activate very_good_cli`

## First-time setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
lefthook install
```

## Running locally

Three flavors: `development`, `staging`, `production`.

```bash
# iOS sim (dev)
flutter run --flavor development --target lib/main_development.dart

# Android emu (dev)
flutter run --flavor development --target lib/main_development.dart -d emulator-5554

# macOS (dev) — plain
flutter run -d macos --flavor development -t lib/main_development.dart

# macOS (dev) — with auto hot-reload on lib/ changes
bash scripts/dev_run.sh

# Production flavor (release-mode build for testing release behavior locally)
flutter run --flavor production --target lib/main_production.dart --release
```

## Codegen (Riverpod / Freezed / JSON / go_router)

```bash
# One-shot
dart run build_runner build --delete-conflicting-outputs

# Watch (recommended during dev)
dart run build_runner watch -d
```

## Running tests

```bash
# Everything except goldens
flutter test --exclude-tags golden

# Goldens (macOS only — Linux font rendering drifts goldens)
flutter test --tags golden

# With coverage
flutter test --coverage
```

## Compliance checks (run before submitting to stores)

```bash
./scripts/check_forbidden_sdks.sh
./scripts/check_no_internet_permission.sh
```

Both are also gated in CI.

## Project structure

```
lib/
  main_development.dart, main_staging.dart, main_production.dart   # flavor entrypoints
  bootstrap.dart                                                    # ProviderScope wrap
  app/                                                              # MaterialApp.router
  core/                                                             # services (audio, locale, settings, gate, routing, theme)
  features/                                                         # screens (home, settings, games/*)
  l10n/                                                             # ar + en arb files, generated localizations
assets/images/, assets/audio/                                       # bundled assets
art/                                                                # source-of-truth art (NOT bundled)
docs/superpowers/                                                   # specs + plans
```

## Hard rules

See [CLAUDE.md](CLAUDE.md) for the canonical list. Highlights:
- No network calls. No `INTERNET` permission on Android release.
- No analytics, crash, or ad SDKs. CI fails on forbidden tokens in `pubspec.lock`.
- No instrumental music.
- No fail states.
- Egyptian Arabic primary; English secondary.

## License

Personal project. License TBD before public publication.
