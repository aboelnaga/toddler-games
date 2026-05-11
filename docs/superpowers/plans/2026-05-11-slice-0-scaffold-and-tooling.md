# Slice 0: Project Scaffold & Tooling — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Stand up the Flutter project with the chosen stack (Riverpod + go_router), full lint/codegen/CI/hooks tooling, AI assistant rules, and compliance hardening — producing an empty app that runs on iOS sim + Android emulator and is ready for feature work. No game logic in this slice.

**Architecture:** Scaffold with Very Good CLI (`very_good_core` template) for flavors/localization/multi-platform baseline. Replace its default Bloc with Riverpod 2.x. Add go_router with typed routes. Layer strict lint stack (`very_good_analysis` + `custom_lint` + `riverpod_lint`). Wire codegen pipeline (build_runner, freezed, riverpod_generator, etc.). Set up Lefthook for pre-commit/pre-push, GitHub Actions for CI. Add AI rules files (`CLAUDE.md` + symlinks). Lock in compliance posture: strip `INTERNET` permission from release Android manifest, ship empty iOS `PrivacyInfo.xcprivacy`, add CI guards against forbidden SDKs.

**Tech Stack:**
- Flutter stable channel + Dart
- Very Good CLI (scaffold)
- `flutter_riverpod` + `riverpod_annotation` + `riverpod_generator`
- `go_router` + `go_router_builder`
- `freezed` + `json_serializable` + `build_runner`
- `very_good_analysis` + `custom_lint` + `riverpod_lint`
- `flutter_launcher_icons` + `flutter_native_splash`
- Lefthook (pre-commit/push hooks)
- GitHub Actions (CI)

**Scope check:** This slice produces a runnable empty app with all conventions in place — no business logic. Subsequent slices (1: app shell, 2: Zoo game, etc.) consume this baseline.

**Companion docs:**
- [Product Requirements](../specs/2026-05-11-toddler-mini-games-prd.md)
- [Design Spec](../specs/2026-05-11-toddler-mini-games-design.md)

**Repo state before this slice:** Just `docs/superpowers/specs/*.md`, `docs/superpowers/plans/*.md`, and `.gitignore`. No Flutter code yet.

---

## File Structure (what this slice creates)

```
.
├── pubspec.yaml                              # Flutter deps + asset registration
├── analysis_options.yaml                     # lint config
├── lefthook.yml                              # pre-commit/push hooks
├── CLAUDE.md                                 # canonical AI rules
├── AGENTS.md                                 # symlink → CLAUDE.md
├── .cursorrules                              # symlink → CLAUDE.md
├── README.md                                 # dev bootstrap instructions
├── .github/
│   └── workflows/
│       ├── ci.yml                            # analyze + format + test
│       └── compliance.yml                    # forbidden-SDK + INTERNET grep
├── lib/
│   ├── main_development.dart                 # entry: dev flavor
│   ├── main_staging.dart                     # entry: staging flavor
│   ├── main_production.dart                  # entry: prod flavor
│   ├── bootstrap.dart                        # shared bootstrap (Riverpod scope)
│   ├── app/
│   │   ├── app.dart                          # MaterialApp.router widget
│   │   └── view/
│   ├── core/
│   │   ├── audio/.gitkeep
│   │   ├── locale/.gitkeep
│   │   ├── settings/.gitkeep
│   │   ├── gate/.gitkeep
│   │   ├── routing/
│   │   │   └── router.dart                   # go_router config
│   │   └── theme/.gitkeep
│   ├── features/
│   │   ├── home/.gitkeep
│   │   ├── settings/.gitkeep
│   │   └── games/
│   │       ├── zoo/.gitkeep
│   │       ├── bubble_pop/.gitkeep
│   │       ├── shape_sorter/.gitkeep
│   │       ├── finger_paint/.gitkeep
│   │       └── drive_vehicle/.gitkeep
│   └── l10n/
│       ├── arb/
│       │   ├── app_en.arb
│       │   └── app_ar.arb                    # ar-EG content
│       └── l10n.dart
├── test/
│   ├── app/
│   │   └── app_test.dart                     # smoke test
│   └── helpers/
│       ├── helpers.dart
│       └── pump_app.dart                     # testing helper
├── assets/
│   ├── images/
│   │   ├── ui/.gitkeep
│   │   └── games/
│   │       ├── zoo/.gitkeep
│   │       ├── bubble_pop/.gitkeep
│   │       ├── shape_sorter/.gitkeep
│   │       ├── finger_paint/.gitkeep
│   │       └── drive_vehicle/.gitkeep
│   └── audio/
│       ├── sfx/.gitkeep
│       ├── ambience/.gitkeep
│       └── voice/
│           ├── ar-EG/.gitkeep
│           └── en/.gitkeep
├── art/
│   └── style-bible/
│       └── README.md                         # how to use the style bible
├── android/
│   └── app/
│       └── src/
│           └── main_production/
│               └── AndroidManifest.xml       # release manifest WITHOUT INTERNET
├── ios/
│   └── Runner/
│       └── PrivacyInfo.xcprivacy             # empty privacy manifest
└── scripts/
    └── check_forbidden_sdks.sh               # CI guard script
```

---

## Task 1: Prerequisites & Very Good CLI Installation

**Files:** none yet — environment setup.

- [ ] **Step 1: Verify Flutter is installed and on stable channel**

Run:
```bash
flutter --version
flutter channel
```
Expected: Flutter 3.x or newer; channel is `stable`. If not, run `flutter channel stable && flutter upgrade`.

- [ ] **Step 2: Verify Dart SDK is available**

Run:
```bash
dart --version
```
Expected: Dart 3.x or newer.

- [ ] **Step 3: Install Very Good CLI**

Run:
```bash
dart pub global activate very_good_cli
```
Expected output: package activated. Confirm the binary is on your PATH (`which very_good` returns a path; if not, add `~/.pub-cache/bin` to your shell PATH and reload).

- [ ] **Step 4: Verify Very Good CLI works**

Run:
```bash
very_good --version
```
Expected: version string printed (e.g., `Very Good CLI Version: 0.x.x`).

- [ ] **Step 5: Verify CocoaPods installed (macOS, for iOS builds)**

Run:
```bash
pod --version
```
Expected: `1.x` or newer. If missing: `sudo gem install cocoapods`.

**No commit yet** — this is environment-level setup.

---

## Task 2: Scaffold Project with Very Good CLI

**Files:**
- Create: many (entire Flutter project tree)
- Modify: `.gitignore` (append Flutter ignores)

- [ ] **Step 1: Scaffold the project into a temporary directory**

The repo root already contains files (`.git/`, `docs/`, `.gitignore`). Very Good CLI creates a new folder by default. Generate it in a sibling temp location, then move contents in.

Run:
```bash
cd /tmp
very_good create flutter_app toddler_games \
  --org com.aboelnaga.toddlergames \
  --description "Bilingual safe mini-games for 2+ year-olds" \
  --application-id com.aboelnaga.toddlergames
```
Expected: `toddler_games/` directory created in `/tmp/` with Flutter project files including dev/staging/production flavors.

- [ ] **Step 2: Move generated files into the repo root**

Run from the repo root:
```bash
cd "/Users/mohamedaboelnaga/github/2+ year Kids games"
# Move dotfiles + folders + files; skip ones we already own (.gitignore, .git, docs)
rsync -av --exclude='.git' --exclude='.gitignore' --exclude='docs/' \
  /tmp/toddler_games/ ./
rm -rf /tmp/toddler_games
```
Expected: project files appear in repo root (`pubspec.yaml`, `lib/`, `test/`, `ios/`, `android/`, etc.) but the existing `docs/` and `.gitignore` are preserved.

- [ ] **Step 3: Merge the generated `.gitignore` into our existing one**

Open `/tmp/toddler_games/.gitignore` content (Flutter standard ignores) and merge into the existing `.gitignore`. The combined `.gitignore` should retain our manual entries and add Flutter's.

Replace the file contents with this merged version:

```gitignore
# Brainstorming session artifacts (visual companion mockups, server state)
.superpowers/

# macOS
.DS_Store

# Editors / IDEs (general)
.idea/
.vscode/
*.swp
*.swo

# Flutter / Dart
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
.fvm/
flutter_*.png
linked_*.ds
unlinked.ds
unlinked_spec.ds
**/doc/api/

# Generated files
*.g.dart
*.freezed.dart
*.gr.dart
*.config.dart

# Coverage
coverage/

# iOS
ios/Flutter/.last_build_id
ios/Pods/
ios/.symlinks/
ios/Flutter/Flutter.framework
ios/Flutter/Flutter.podspec
ios/Flutter/ephemeral/
ios/Runner/GeneratedPluginRegistrant.*
*.ipa
*.mode1v3
*.mode2v3
*.moved-aside
*.pbxuser
*.perspectivev3
**/*sync/
.sconsign.dblite
.tags*
**/.vagrant/
**/DerivedData/
Icon?
**/Pods/
**/.symlinks/
profile
xcuserdata/
**/.generated/
Flutter/app.flx
Flutter/app.zip
Flutter/flutter_assets/
Flutter/flutter_export_environment.sh
ServiceDefinitions.json
Runner/GeneratedPluginRegistrant.*

# Android
**/android/**/gradle-wrapper.jar
.gradle/
**/android/captures/
**/android/gradlew
**/android/gradlew.bat
**/android/local.properties
**/android/**/GeneratedPluginRegistrant.java
**/android/key.properties
*.jks

# Lefthook (local config)
.lefthook-local.yml

# Environment files (none expected, but defensive)
.env
.env.*
```

- [ ] **Step 4: Initial sanity build to confirm scaffold works**

Run:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs || true
flutter analyze
```
Expected: `pub get` succeeds; analyze may report issues we'll fix; build_runner may have nothing to generate yet (harmless `|| true`).

- [ ] **Step 5: Run the dev flavor app to confirm it launches**

Run (in two separate terminals or one after the other, depending on simulator availability):
```bash
# iOS sim
flutter run --flavor development --target lib/main_development.dart -d "iPhone 15"
# Stop with q after confirming launch
```
Expected: app builds, launches on simulator, shows the VGV default counter app or template scaffold. **Take a screenshot or note "launched OK" — that's the green light.**

```bash
# Android emu
flutter run --flavor development --target lib/main_development.dart -d emulator-5554
```
Expected: same.

If either platform fails, do not proceed. Resolve before continuing.

- [ ] **Step 6: Commit the scaffold**

```bash
git add .
git status
# Verify .gitignore is properly excluding build artifacts, .dart_tool, etc.
git commit -m "Scaffold Flutter project with very_good_cli (core template)

Generated via:
  very_good create flutter_app toddler_games \\
    --org com.aboelnaga.toddlergames \\
    --description ... \\
    --application-id com.aboelnaga.toddlergames

Includes flavors (dev/staging/production), arb localization scaffold,
test helpers, GitHub Actions templates (to be replaced).

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

Expected: commit lands; `git log --oneline` shows the new commit alongside the spec/PRD commits.

---

## Task 3: Replace Bloc with Riverpod 2.x

VGV ships `flutter_bloc` by default. We swap it for Riverpod.

**Files:**
- Modify: `pubspec.yaml` (remove bloc deps, add riverpod deps)
- Modify: `lib/bootstrap.dart` (wrap app in `ProviderScope`)
- Modify: `lib/counter/...` (delete Bloc-based counter feature) — or remove the whole `counter/` directory since we don't need a counter
- Modify: `test/counter/...` (delete)

- [ ] **Step 1: Inspect existing `pubspec.yaml` and identify Bloc deps**

Run:
```bash
grep -n "bloc" pubspec.yaml
```
Expected output: lines like `flutter_bloc: ^x.y.z` and `bloc_test: ^x.y.z` (in dev_dependencies).

Note these line numbers — we'll remove them.

- [ ] **Step 2: Edit `pubspec.yaml` to swap deps**

Open `pubspec.yaml`. In the `dependencies:` section, remove the `flutter_bloc` line and add:

```yaml
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
```

In `dev_dependencies:`, remove `bloc_test` and add:

```yaml
  riverpod_generator: ^2.4.0
  riverpod_lint: ^2.3.10
  custom_lint: ^0.6.4
```

(Adjust versions to the latest stable when running, but keep `riverpod_lint` and `riverpod_generator` matching minor versions.)

- [ ] **Step 3: Run pub get to fetch new deps**

Run:
```bash
flutter pub get
```
Expected: dependencies resolve successfully.

- [ ] **Step 4: Delete the Bloc-based counter feature scaffold**

The VGV template includes a counter demo. Remove it:

```bash
rm -rf lib/counter
rm -rf test/counter
```

- [ ] **Step 5: Update `lib/bootstrap.dart` to wrap app in `ProviderScope`**

Open `lib/bootstrap.dart`. The current file initializes the app via `runApp(await builder())`. Change it to wrap with Riverpod's scope:

Replace the body of `bootstrap()` so it looks like (key change is the `ProviderScope` wrapper):

```dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppBlocObserver {
  // Keep VGV's observer scaffolding only if you want to add observer-style logs.
  // For now, we delete bloc-specific observer code.
}

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc?.observer = null; // remove if Bloc import is gone

  runApp(
    ProviderScope(
      child: await builder(),
    ),
  );
}
```

Actually — since we removed Bloc entirely, also remove all `flutter_bloc` imports and any references to `Bloc.observer` from `bootstrap.dart`. The cleaned-up version:

```dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  runApp(
    ProviderScope(
      child: await builder(),
    ),
  );
}
```

- [ ] **Step 6: Replace `lib/app/view/app.dart` body to drop Bloc references**

Open `lib/app/view/app.dart`. The VGV template likely references the Counter feature. Replace the file contents with a minimal MaterialApp that just shows a Placeholder for now:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(color: const Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(
        body: Center(
          child: Text('Toddler Games — scaffold ready'),
        ),
      ),
    );
  }
}
```

(We'll replace this with `MaterialApp.router` + go_router in Task 4.)

- [ ] **Step 7: Run analyze to surface remaining Bloc references**

Run:
```bash
flutter analyze
```
Expected: any remaining `bloc`/`Bloc` references show up as errors. Fix each by deleting the offending import / line, or by removing the file entirely if it was Bloc-specific.

- [ ] **Step 8: Run the smoke test to confirm scaffold still builds**

Run:
```bash
flutter test test/app/app_test.dart
```
Expected: test may need updating since we changed the App body. Open `test/app/app_test.dart` and update the assertion to match the new placeholder body:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/app/app.dart';

void main() {
  group('App', () {
    testWidgets('renders scaffold placeholder', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.text('Toddler Games — scaffold ready'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 9: Run the test again to confirm it passes**

Run:
```bash
flutter test test/app/app_test.dart
```
Expected: PASS.

- [ ] **Step 10: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/ test/
git commit -m "Replace Bloc with Riverpod 2.x

- Remove flutter_bloc, bloc_test
- Add flutter_riverpod, riverpod_annotation, riverpod_generator,
  riverpod_lint, custom_lint
- Wrap app in ProviderScope in bootstrap()
- Delete counter feature scaffold (Bloc demo)
- Reduce App widget to a placeholder until go_router lands in next task

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: Add go_router with Typed Routes

**Files:**
- Modify: `pubspec.yaml` (add go_router + go_router_builder)
- Create: `lib/core/routing/router.dart` (router config + typed routes)
- Modify: `lib/app/view/app.dart` (switch to `MaterialApp.router`)
- Create: `lib/features/home/home_screen.dart` (placeholder home)
- Create: `lib/features/settings/settings_screen.dart` (placeholder settings)
- Test: `test/core/routing/router_test.dart`

- [ ] **Step 1: Add routing deps to `pubspec.yaml`**

In `dependencies:` add:

```yaml
  go_router: ^14.2.0
```

In `dev_dependencies:` add:

```yaml
  go_router_builder: ^2.7.0
```

Run:
```bash
flutter pub get
```

- [ ] **Step 2: Create the placeholder home screen**

Create `lib/features/home/home_screen.dart`:

```dart
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Home (scaffold)'),
      ),
    );
  }
}
```

- [ ] **Step 3: Create the placeholder settings screen**

Create `lib/features/settings/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Settings (scaffold)'),
      ),
    );
  }
}
```

- [ ] **Step 4: Write the failing router test**

Create `test/core/routing/router_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/routing/router.dart';

void main() {
  group('router', () {
    testWidgets('navigates / to HomeScreen', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      expect(find.text('Home (scaffold)'), findsOneWidget);
    });

    testWidgets('navigates to /settings', (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      router.go('/settings');
      await tester.pumpAndSettle();

      expect(find.text('Settings (scaffold)'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 5: Run the test to confirm it fails (router module doesn't exist yet)**

Run:
```bash
flutter test test/core/routing/router_test.dart
```
Expected: FAIL with "uri target router.dart doesn't exist" or similar import error.

- [ ] **Step 6: Create the router module**

Create `lib/core/routing/router.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});
```

(We'll add `/game/:id` and `/parent-gate` in Slice 1 when we have a real parent gate.)

- [ ] **Step 7: Update `lib/app/view/app.dart` to use `MaterialApp.router`**

Replace the contents of `lib/app/view/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/routing/router.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Color(0xFF13B9FF)),
        colorScheme: ColorScheme.fromSwatch(
          accentColor: const Color(0xFF13B9FF),
        ),
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 8: Update the app smoke test to match**

Edit `test/app/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/app/app.dart';

void main() {
  group('App', () {
    testWidgets('boots into HomeScreen', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: App()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home (scaffold)'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 9: Run all tests**

Run:
```bash
flutter test
```
Expected: PASS. All three tests (router/home + router/settings + app smoke) green.

- [ ] **Step 10: Run the app to verify on simulator**

Run:
```bash
flutter run --flavor development --target lib/main_development.dart -d "iPhone 15"
```
Expected: app shows "Home (scaffold)" centered on screen.

- [ ] **Step 11: Commit**

```bash
git add .
git commit -m "Add go_router with typed-style provider-based config

- Add go_router 14.x and go_router_builder
- Create lib/core/routing/router.dart with routerProvider
- Add placeholder HomeScreen and SettingsScreen
- Switch App to MaterialApp.router, consume routerProvider via Riverpod
- Add router widget tests

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: Lint Stack — very_good_analysis + riverpod_lint

**Files:**
- Modify: `analysis_options.yaml`
- Modify: `pubspec.yaml` (replace flutter_lints with very_good_analysis if present)

- [ ] **Step 1: Inspect current `analysis_options.yaml`**

Run:
```bash
cat analysis_options.yaml
```
Note its current content (VGV likely already extends `very_good_analysis` — confirm and adapt accordingly).

- [ ] **Step 2: Remove `flutter_lints` if present**

If `pubspec.yaml` contains `flutter_lints` in dev_dependencies, remove that line and run:
```bash
flutter pub get
```

- [ ] **Step 3: Ensure `very_good_analysis` is in `dev_dependencies`**

In `pubspec.yaml`, confirm:
```yaml
  very_good_analysis: ^6.0.0  # or latest 6.x or 9.x at time of install
```

Run:
```bash
flutter pub get
```

- [ ] **Step 4: Update `analysis_options.yaml` to enable plugin & include**

Replace the file with:

```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  plugins:
    - custom_lint
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/generated/**"
    - "**/l10n/generated/**"

linter:
  rules:
    # Override or relax specific very_good_analysis rules as needed.
    # Start with no overrides — add only when a real rule causes friction.
```

- [ ] **Step 5: Run analyze to confirm the lint stack works**

Run:
```bash
flutter analyze
dart run custom_lint
```
Expected: both commands exit with 0 errors (warnings are OK). If errors appear, fix them inline — they're real signal.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock analysis_options.yaml
git commit -m "Configure strict lint stack

- Adopt very_good_analysis as the base rule set
- Enable custom_lint plugin (drives riverpod_lint)
- Exclude generated files (*.g.dart, *.freezed.dart, l10n)
- Remove flutter_lints (less strict, redundant)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Codegen Pipeline — build_runner + freezed + json_serializable

**Files:**
- Modify: `pubspec.yaml` (add freezed, json_serializable, build_runner)
- Create: `build.yaml` (optional — only if we need custom builder config)
- Create: a placeholder `lib/core/settings/settings_state.dart` to verify codegen works end-to-end

- [ ] **Step 1: Add codegen deps**

In `dev_dependencies:` of `pubspec.yaml`, add:

```yaml
  build_runner: ^2.4.13
  freezed: ^2.5.7
  json_serializable: ^6.8.0
```

In `dependencies:` add:

```yaml
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
```

Run:
```bash
flutter pub get
```

- [ ] **Step 2: Verify build_runner works with a tiny freezed model**

Create `lib/core/settings/settings_state.dart`:

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';
part 'settings_state.g.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default('ar-EG') String locale,
    @Default(true) bool soundEnabled,
    @Default(<String>['zoo', 'bubble_pop', 'shape_sorter', 'finger_paint', 'drive_vehicle'])
    List<String> enabledGames,
  }) = _SettingsState;

  factory SettingsState.fromJson(Map<String, Object?> json) =>
      _$SettingsStateFromJson(json);
}
```

- [ ] **Step 3: Run codegen**

Run:
```bash
dart run build_runner build --delete-conflicting-outputs
```
Expected: generates `settings_state.freezed.dart` and `settings_state.g.dart` next to the source.

- [ ] **Step 4: Verify generated files exist**

Run:
```bash
ls lib/core/settings/
```
Expected: `settings_state.dart`, `settings_state.freezed.dart`, `settings_state.g.dart`.

- [ ] **Step 5: Verify analyze still passes**

Run:
```bash
flutter analyze
dart run custom_lint
```
Expected: clean.

- [ ] **Step 6: Add a quick smoke test for the model**

Create `test/core/settings/settings_state_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  group('SettingsState', () {
    test('defaults to Egyptian Arabic, sound on, all games enabled', () {
      const state = SettingsState();
      expect(state.locale, 'ar-EG');
      expect(state.soundEnabled, isTrue);
      expect(state.enabledGames, hasLength(5));
      expect(state.enabledGames, contains('zoo'));
    });

    test('round-trips through JSON', () {
      const state = SettingsState(locale: 'en', soundEnabled: false);
      final json = state.toJson();
      final decoded = SettingsState.fromJson(json);
      expect(decoded, state);
    });
  });
}
```

- [ ] **Step 7: Run the test**

Run:
```bash
flutter test test/core/settings/settings_state_test.dart
```
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/settings/ test/core/settings/
git commit -m "Wire up build_runner + freezed + json_serializable codegen

- Add freezed, json_serializable, json_annotation, build_runner
- Verify pipeline with placeholder SettingsState model
- Generated files: settings_state.freezed.dart, settings_state.g.dart

Standing command: dart run build_runner watch -d

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Localization — ar-EG (default) + en

**Files:**
- Modify: `pubspec.yaml` (l10n config)
- Modify or Create: `lib/l10n/arb/app_en.arb`
- Modify or Create: `lib/l10n/arb/app_ar.arb` (Egyptian content)
- Create: `l10n.yaml` if not generated by VGV

- [ ] **Step 1: Inspect the existing l10n setup VGV provided**

Run:
```bash
ls lib/l10n/
cat l10n.yaml 2>/dev/null || echo "no l10n.yaml"
```

VGV's core template usually generates `lib/l10n/arb/app_en.arb` + a default counter-related string. We'll set Arabic as primary.

- [ ] **Step 2: Configure `l10n.yaml` for ar-EG primary**

Create or update `l10n.yaml` at repo root:

```yaml
arb-dir: lib/l10n/arb
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
preferred-supported-locales:
  - ar
nullable-getter: false
```

(Template uses English as the *template arb* because tooling expects an English fallback; runtime default is set in `MaterialApp` and selectable via the locale provider we'll build in Slice 1.)

- [ ] **Step 3: Define initial strings for English**

Replace `lib/l10n/arb/app_en.arb` content with:

```json
{
  "@@locale": "en",
  "appTitle": "Toddler Games",
  "@appTitle": {
    "description": "App display name shown in store and on splash"
  },
  "homeTitle": "Home",
  "@homeTitle": {
    "description": "Title for the home screen (hidden in v1; tiles are images)"
  },
  "settingsTitle": "Settings",
  "@settingsTitle": {
    "description": "Title for the parent settings screen"
  }
}
```

- [ ] **Step 4: Define initial strings for Egyptian Arabic**

Create `lib/l10n/arb/app_ar.arb`:

```json
{
  "@@locale": "ar",
  "appTitle": "ألعاب الأطفال",
  "homeTitle": "الرئيسية",
  "settingsTitle": "الإعدادات"
}
```

(Note: the file is `app_ar.arb` because Flutter's gen-l10n uses ISO codes. We'll handle the `ar-EG` distinction in the runtime locale provider in Slice 1 — for now, `ar` is fine and the strings are Egyptian-flavored.)

- [ ] **Step 5: Regenerate localizations**

Run:
```bash
flutter gen-l10n
```
Expected: generates `lib/l10n/generated/app_localizations.dart` (and `app_localizations_en.dart`, `app_localizations_ar.dart`).

- [ ] **Step 6: Update `pubspec.yaml` `flutter:` section to register `flutter_localizations` if missing**

Confirm `pubspec.yaml` has:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter

flutter:
  generate: true
```

If `flutter_localizations` is missing or `generate: true` isn't there, add them and `flutter pub get`.

- [ ] **Step 7: Add a localization smoke test**

Create `test/l10n/localization_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLocalizations', () {
    testWidgets('renders English strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: Builder(
            builder: (context) {
              final l = AppLocalizations.of(context)!;
              return Text(l.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Toddler Games'), findsOneWidget);
    });

    testWidgets('renders Arabic strings', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ar'),
          home: Builder(
            builder: (context) {
              final l = AppLocalizations.of(context)!;
              return Text(l.appTitle);
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('ألعاب الأطفال'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 8: Run the test**

Run:
```bash
flutter test test/l10n/localization_test.dart
```
Expected: PASS.

- [ ] **Step 9: Commit**

```bash
git add pubspec.yaml l10n.yaml lib/l10n/ test/l10n/
git commit -m "Configure localization for ar (default) + en

- Set up gen-l10n with ar-EG primary, en secondary
- Initial strings: appTitle, homeTitle, settingsTitle
- Add smoke tests for both locales

Runtime locale selection lands in Slice 1.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Folder Structure & Asset Layout

Create the empty folder skeleton from the design spec so subsequent slices have known homes.

**Files:**
- Create: many `.gitkeep` files in empty folders
- Create: `art/style-bible/README.md`

- [ ] **Step 1: Create the core/ subfolder skeleton**

Run:
```bash
mkdir -p lib/core/{audio,locale,gate,theme}
touch lib/core/audio/.gitkeep
touch lib/core/locale/.gitkeep
touch lib/core/gate/.gitkeep
touch lib/core/theme/.gitkeep
```

(`lib/core/settings/` already exists with the SettingsState model from Task 6. `lib/core/routing/` already exists with router.dart from Task 4.)

- [ ] **Step 2: Create the features/games/ subfolder skeleton**

Run:
```bash
mkdir -p lib/features/games/{zoo,bubble_pop,shape_sorter,finger_paint,drive_vehicle}
for g in zoo bubble_pop shape_sorter finger_paint drive_vehicle; do
  touch "lib/features/games/$g/.gitkeep"
done
```

- [ ] **Step 3: Create the assets/ tree**

Run:
```bash
mkdir -p assets/images/ui
mkdir -p assets/images/games/{zoo,bubble_pop,shape_sorter,finger_paint,drive_vehicle}
mkdir -p assets/audio/sfx
mkdir -p assets/audio/ambience
mkdir -p assets/audio/voice/{ar-EG,en}

for d in \
  assets/images/ui \
  assets/images/games/zoo \
  assets/images/games/bubble_pop \
  assets/images/games/shape_sorter \
  assets/images/games/finger_paint \
  assets/images/games/drive_vehicle \
  assets/audio/sfx \
  assets/audio/ambience \
  assets/audio/voice/ar-EG \
  assets/audio/voice/en \
; do
  touch "$d/.gitkeep"
done
```

- [ ] **Step 4: Create the art/ folder (NOT bundled into the app)**

```bash
mkdir -p art/style-bible
```

Create `art/style-bible/README.md`:

```markdown
# Style Bible

This folder holds source-of-truth art references for the project. **It is NOT bundled into the shipped app.**

## What lives here

- `mascot-fox.png` — the master reference image generated via Nano Banana (Gemini 2.5 Flash Image). Every subsequent generation references this image.
- `reference-scenes/` — scene-level references (zoo backdrop, road for vehicle game, etc.).
- `master-prompt.md` — the master prompt verbatim, plus prompt fragments for each asset type.
- `palette.md` — hex codes and usage rules.

## How to add a new asset

1. Open Google AI Studio (https://aistudio.google.com), Playground.
2. Select Gemini 2.5 Flash Image as the model.
3. Upload `mascot-fox.png` as a reference image.
4. Paste the relevant prompt fragment from `master-prompt.md`.
5. Generate. Iterate until happy.
6. Save the **source** to `art/style-bible/` (NOT to `assets/`).
7. Optimize a derivative (WebP, sized to target use) into `assets/images/games/<game>/`.

## Why source art is NOT bundled

Style-bible images are large, high-resolution masters. Bundling them inflates the app binary unnecessarily and risks pushing the APK past size thresholds that trigger store-review scrutiny.
```

- [ ] **Step 5: Update `pubspec.yaml` to register asset directories**

In `pubspec.yaml`, in the `flutter:` section, add:

```yaml
flutter:
  generate: true
  uses-material-design: true
  assets:
    - assets/images/ui/
    - assets/images/games/zoo/
    - assets/images/games/bubble_pop/
    - assets/images/games/shape_sorter/
    - assets/images/games/finger_paint/
    - assets/images/games/drive_vehicle/
    - assets/audio/sfx/
    - assets/audio/ambience/
    - assets/audio/voice/ar-EG/
    - assets/audio/voice/en/
```

(Flutter ignores empty asset folders, so this works fine even with only `.gitkeep` in each.)

- [ ] **Step 6: Run pub get + analyze to confirm**

Run:
```bash
flutter pub get
flutter analyze
flutter test
```
Expected: clean. All tests still pass.

- [ ] **Step 7: Commit**

```bash
git add lib/ assets/ art/ pubspec.yaml
git commit -m "Add folder structure for core, features, assets, art

- lib/core/{audio,locale,gate,theme} with .gitkeep stubs
- lib/features/games/{zoo,bubble_pop,shape_sorter,finger_paint,drive_vehicle}
- assets/{images,audio} tree with locale-namespaced voice subfolders
- art/style-bible/ with README explaining the Nano Banana workflow
- Register asset directories in pubspec.yaml

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: AI Assistant Rules — CLAUDE.md + symlinks

**Files:**
- Create: `CLAUDE.md`
- Create: `AGENTS.md` (symlink → CLAUDE.md)
- Create: `.cursorrules` (symlink → CLAUDE.md)

- [ ] **Step 1: Create CLAUDE.md**

Create `CLAUDE.md` at repo root with:

````markdown
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
- State: Riverpod 2.x (prefer `@riverpod` generator)
- Routing: go_router 14.x (typed routes via go_router_builder when feasible)
- Localization: gen-l10n with `.arb` files in `lib/l10n/arb/`
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
- Prefer immutable models via `freezed`.

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
````

- [ ] **Step 2: Create AGENTS.md as a symlink**

```bash
cd "/Users/mohamedaboelnaga/github/2+ year Kids games"
ln -s CLAUDE.md AGENTS.md
```

Verify:
```bash
ls -la AGENTS.md
```
Expected output: `AGENTS.md -> CLAUDE.md`.

- [ ] **Step 3: Create .cursorrules as a symlink**

```bash
ln -s CLAUDE.md .cursorrules
```

Verify:
```bash
ls -la .cursorrules
```
Expected: `.cursorrules -> CLAUDE.md`.

- [ ] **Step 4: Commit**

```bash
git add CLAUDE.md AGENTS.md .cursorrules
git commit -m "Add AI assistant rules (CLAUDE.md) + AGENTS.md / .cursorrules symlinks

Canonical rules in CLAUDE.md cover:
- Hard invariants (no network, no analytics, no music, no fail states,
  bilingual Egyptian-Arabic primary, no in-game text)
- Tech stack and codegen workflow
- Code style, testing layout, golden test conventions
- What not to do (forbidden SDKs, hand-edited generated files, etc.)

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 10: Compliance Hardening — Android INTERNET, iOS PrivacyInfo

**Files:**
- Modify: `android/app/src/main/AndroidManifest.xml` and per-flavor manifests
- Create: `ios/Runner/PrivacyInfo.xcprivacy`
- Modify: `ios/Runner.xcodeproj/project.pbxproj` (register the file in the bundle)

- [ ] **Step 1: Find every AndroidManifest in the project**

Run:
```bash
find android -name "AndroidManifest.xml"
```

Expected (VGV core ships per-flavor manifests):
```
android/app/src/main/AndroidManifest.xml
android/app/src/development/AndroidManifest.xml
android/app/src/staging/AndroidManifest.xml
android/app/src/production/AndroidManifest.xml
android/app/src/debug/AndroidManifest.xml
android/app/src/profile/AndroidManifest.xml
```

If per-flavor manifests don't exist, the `main/` manifest applies to all flavors.

- [ ] **Step 2: Grep every manifest for `INTERNET`**

Run:
```bash
grep -rn "android.permission.INTERNET" android/
```

Expected: probably zero hits — Flutter does not request INTERNET by default in release builds. If hits appear, note the locations.

- [ ] **Step 3: Ensure no INTERNET permission anywhere in production manifests**

If a production manifest (or main manifest) contains:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```
remove that line. The debug-flavor manifest typically declares INTERNET (Flutter needs it for hot reload) — that's fine; only the production flavor must lack it.

- [ ] **Step 4: Add an explicit `<uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>` to the production manifest**

This is belt-and-suspenders — explicitly removes any INTERNET permission a transitive dependency might try to add.

Edit `android/app/src/production/AndroidManifest.xml`. Inside the `<manifest>` tag, add (with the `tools` namespace if not already declared):

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />

    <application ...>
        <!-- existing application body unchanged -->
    </application>
</manifest>
```

If the production manifest file doesn't exist, create it with the minimum content:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">
    <uses-permission android:name="android.permission.INTERNET" tools:node="remove" />
</manifest>
```

Flutter's build system will merge this with the main manifest.

- [ ] **Step 5: Create iOS PrivacyInfo.xcprivacy**

Create `ios/Runner/PrivacyInfo.xcprivacy`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSPrivacyTracking</key>
    <false/>
    <key>NSPrivacyTrackingDomains</key>
    <array/>
    <key>NSPrivacyCollectedDataTypes</key>
    <array/>
    <key>NSPrivacyAccessedAPITypes</key>
    <array/>
</dict>
</plist>
```

- [ ] **Step 6: Register PrivacyInfo.xcprivacy in the Xcode project**

The file must be part of the bundle. Open `ios/Runner.xcodeproj` in Xcode:
1. Right-click `Runner` → "Add Files to Runner..."
2. Select `PrivacyInfo.xcprivacy`
3. Ensure "Copy items if needed" is checked and target membership includes `Runner`
4. Save and close

Alternatively, edit `ios/Runner.xcodeproj/project.pbxproj` directly (more error-prone; prefer Xcode). The file should be referenced under the Runner build phase "Copy Bundle Resources."

Verify by running:
```bash
flutter build ios --no-codesign --flavor production
```
And searching the build log for `PrivacyInfo.xcprivacy` — it should be copied.

- [ ] **Step 7: Commit**

```bash
git add android/ ios/
git commit -m "Compliance hardening: strip Android INTERNET, add iOS privacy manifest

- Android production flavor: explicitly remove INTERNET permission via
  tools:node=remove in manifest merger
- iOS: ship empty PrivacyInfo.xcprivacy declaring no tracking, no
  collected data types, no accessed API types

These changes are required for Apple Kids Category + Google Play Designed
for Families and satisfy our zero-data-collection posture.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 11: CI Safety Guards — Forbidden SDK + INTERNET Grep

**Files:**
- Create: `scripts/check_forbidden_sdks.sh`
- Create: `scripts/check_no_internet_permission.sh`
- Modify: `.github/workflows/` (we'll set up the workflow in Task 12 — script tests come first)

- [ ] **Step 1: Create the forbidden-SDK check script**

Create `scripts/check_forbidden_sdks.sh`:

```bash
#!/usr/bin/env bash
# Fails if pubspec.lock contains any forbidden third-party SDK that violates
# our zero-data-collection compliance posture.
#
# See: docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md §6
# and CLAUDE.md "Hard invariants".

set -euo pipefail

FORBIDDEN_PATTERNS=(
  "firebase_"
  "sentry"
  "mixpanel"
  "amplitude"
  "facebook_"
  "appsflyer"
  "branch_io"
  "onesignal"
)

LOCKFILE="pubspec.lock"
if [[ ! -f "$LOCKFILE" ]]; then
  echo "ERROR: $LOCKFILE not found. Run flutter pub get first."
  exit 2
fi

FOUND=()
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
  if grep -i -E "^\s+${pattern}" "$LOCKFILE" > /dev/null 2>&1; then
    matches=$(grep -i -E "^\s+${pattern}" "$LOCKFILE" || true)
    FOUND+=("$pattern: $matches")
  fi
done

if [[ ${#FOUND[@]} -gt 0 ]]; then
  echo "Compliance check FAILED. Forbidden SDK(s) detected in $LOCKFILE:"
  for entry in "${FOUND[@]}"; do
    echo "  - $entry"
  done
  echo ""
  echo "This app's compliance posture is zero data collection."
  echo "Adding any of these SDKs requires explicit user approval and a"
  echo "memo updating the design spec. See CLAUDE.md."
  exit 1
fi

echo "OK: no forbidden SDKs detected in $LOCKFILE."
exit 0
```

- [ ] **Step 2: Make it executable and run it**

Run:
```bash
chmod +x scripts/check_forbidden_sdks.sh
./scripts/check_forbidden_sdks.sh
```
Expected: `OK: no forbidden SDKs detected in pubspec.lock.`

- [ ] **Step 3: Test that the script catches a violation**

Temporarily add a forbidden dep to verify the script fails. Run:
```bash
# Temporarily inject a fake forbidden entry
cp pubspec.lock pubspec.lock.bak
echo "  firebase_analytics:" >> pubspec.lock
echo "    dependency: \"direct main\"" >> pubspec.lock

./scripts/check_forbidden_sdks.sh
```
Expected: script exits with code 1 and prints the violation.

Restore:
```bash
mv pubspec.lock.bak pubspec.lock
./scripts/check_forbidden_sdks.sh
```
Expected: OK again.

- [ ] **Step 4: Create the INTERNET-permission check script**

Create `scripts/check_no_internet_permission.sh`:

```bash
#!/usr/bin/env bash
# Fails if any production-flavor Android manifest declares
# android.permission.INTERNET *without* tools:node="remove".
#
# Allowed: <uses-permission android:name="android.permission.INTERNET" tools:node="remove"/>
# Forbidden: <uses-permission android:name="android.permission.INTERNET"/>

set -euo pipefail

# Check all production-flavor manifests (and main if no production override exists).
MANIFESTS=()
if [[ -f android/app/src/production/AndroidManifest.xml ]]; then
  MANIFESTS+=("android/app/src/production/AndroidManifest.xml")
fi
MANIFESTS+=("android/app/src/main/AndroidManifest.xml")

VIOLATIONS=()
for m in "${MANIFESTS[@]}"; do
  if [[ ! -f "$m" ]]; then
    continue
  fi
  # Look for the INTERNET permission line that does NOT contain tools:node="remove"
  if grep -E 'android.permission.INTERNET' "$m" | grep -v 'tools:node="remove"' > /dev/null 2>&1; then
    VIOLATIONS+=("$m")
  fi
done

if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  echo "Compliance check FAILED. INTERNET permission detected in production manifest(s):"
  for v in "${VIOLATIONS[@]}"; do
    echo "  - $v"
  done
  echo ""
  echo "The release flavor must not declare INTERNET. The app is offline."
  echo "If you need INTERNET in debug for hot reload, declare it only in"
  echo "android/app/src/debug/AndroidManifest.xml."
  exit 1
fi

echo "OK: no INTERNET permission detected in production manifests."
exit 0
```

- [ ] **Step 5: Make it executable and run it**

```bash
chmod +x scripts/check_no_internet_permission.sh
./scripts/check_no_internet_permission.sh
```
Expected: `OK: no INTERNET permission detected in production manifests.`

- [ ] **Step 6: Commit**

```bash
git add scripts/
git commit -m "Add CI safety guard scripts

- scripts/check_forbidden_sdks.sh: fails build if pubspec.lock contains
  firebase_, sentry, mixpanel, amplitude, facebook_, appsflyer, etc.
- scripts/check_no_internet_permission.sh: fails build if production
  Android manifest declares INTERNET without tools:node=remove

These guards enforce the zero-data-collection compliance posture
mechanically, so a careless dep addition can't silently break review.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 12: GitHub Actions CI

**Files:**
- Create or Modify: `.github/workflows/ci.yml`
- Create: `.github/workflows/compliance.yml`

VGV likely generated a starter workflow — we'll replace it with a tailored one.

- [ ] **Step 1: Inspect existing workflows**

```bash
ls -la .github/workflows/
```
Note what's there. If a VGV-generated `main.yml` or similar exists, we'll replace its content.

- [ ] **Step 2: Write the CI workflow**

Create or replace `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  analyze:
    name: Format + Analyze
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Pub get
        run: flutter pub get
      - name: Codegen
        run: dart run build_runner build --delete-conflicting-outputs
      - name: Format check
        run: dart format --set-exit-if-changed .
      - name: Analyze
        run: flutter analyze --fatal-infos
      - name: Custom lint (Riverpod)
        run: dart run custom_lint

  test:
    name: Tests (Linux, non-golden)
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Pub get
        run: flutter pub get
      - name: Codegen
        run: dart run build_runner build --delete-conflicting-outputs
      - name: Test (exclude golden)
        run: flutter test --exclude-tags golden --coverage

  goldens:
    name: Golden Tests (macOS only)
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Pub get
        run: flutter pub get
      - name: Codegen
        run: dart run build_runner build --delete-conflicting-outputs
      - name: Golden tests
        run: flutter test --tags golden
```

- [ ] **Step 3: Write the compliance workflow**

Create `.github/workflows/compliance.yml`:

```yaml
name: Compliance

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  forbidden-sdks:
    name: Check for forbidden SDKs
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
          cache: true
      - name: Pub get
        run: flutter pub get
      - name: Forbidden SDK check
        run: ./scripts/check_forbidden_sdks.sh

  no-internet-permission:
    name: Check no INTERNET permission in release manifest
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: INTERNET permission check
        run: ./scripts/check_no_internet_permission.sh
```

- [ ] **Step 4: Remove old VGV-generated workflows if they conflict**

If there's a `main.yml` or `.semantic.yml` or anything that duplicates what we just wrote, delete it:

```bash
# Inspect first
ls .github/workflows/
# If you see e.g. main.yml from VGV, decide whether to merge or delete.
# rm .github/workflows/main.yml  # only if duplicative
```

- [ ] **Step 5: Commit**

```bash
git add .github/
git commit -m "Set up GitHub Actions CI

Two workflows:
- ci.yml: format check, analyze, custom_lint, tests on Linux,
  golden tests on macOS (Linux font rendering drifts goldens)
- compliance.yml: forbidden-SDK + INTERNET-permission grep guards

Tests are split by tag: 'golden' tag runs only on macOS runners.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 13: Lefthook — Pre-commit & Pre-push Hooks

**Files:**
- Create: `lefthook.yml`
- Document: installation step in README

- [ ] **Step 1: Install lefthook locally**

Run:
```bash
brew install lefthook
# or, if you prefer the npm route:
# npm install -g lefthook
```
Verify:
```bash
lefthook version
```

- [ ] **Step 2: Create `lefthook.yml`**

Create `lefthook.yml` at repo root:

```yaml
pre-commit:
  parallel: true
  commands:
    format:
      glob: "*.dart"
      run: dart format --set-exit-if-changed {staged_files}
    analyze:
      glob: "*.dart"
      run: flutter analyze --fatal-infos

pre-push:
  parallel: false
  commands:
    test:
      run: flutter test --exclude-tags golden
    custom-lint:
      run: dart run custom_lint
    forbidden-sdks:
      run: ./scripts/check_forbidden_sdks.sh
    internet-permission:
      run: ./scripts/check_no_internet_permission.sh
```

- [ ] **Step 3: Install the git hooks**

Run:
```bash
lefthook install
```
Expected output: hooks installed in `.git/hooks/`.

- [ ] **Step 4: Test the hooks by attempting a commit**

Make a trivial change (e.g., add a comment to `lib/main_development.dart`):
```bash
echo "// trigger hook test" >> lib/main_development.dart
git add lib/main_development.dart
git commit -m "Test lefthook"
```
Expected: format + analyze run; commit succeeds. If format fixes the file, you may need to `git add` again.

Revert the test:
```bash
git reset HEAD~1
git checkout lib/main_development.dart
```

- [ ] **Step 5: Commit the hook config**

```bash
git add lefthook.yml
git commit -m "Add Lefthook pre-commit and pre-push hooks

Pre-commit: dart format --set-exit-if-changed + flutter analyze
Pre-push: flutter test + custom_lint + forbidden-SDKs + INTERNET check

Local install: brew install lefthook && lefthook install

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 14: Launcher Icons & Native Splash (Placeholder Assets)

**Files:**
- Modify: `pubspec.yaml` (add flutter_launcher_icons + flutter_native_splash configs)
- Create: `assets/images/ui/icon-placeholder.png` (a simple solid-color placeholder — real icon comes once style bible is generated)

- [ ] **Step 1: Add deps**

In `pubspec.yaml` `dev_dependencies:` add:

```yaml
  flutter_launcher_icons: ^0.14.1
  flutter_native_splash: ^2.4.1
```

Run:
```bash
flutter pub get
```

- [ ] **Step 2: Create a placeholder icon**

For now, create a simple PNG. You can use any 1024x1024 placeholder. Easy options:
- Generate a solid-color PNG with ImageMagick: `convert -size 1024x1024 xc:'#ff8c42' assets/images/ui/icon-placeholder.png`
- Or download any 1024x1024 placeholder image and save to `assets/images/ui/icon-placeholder.png`.

This will be replaced when the real fox mascot is finalized.

- [ ] **Step 3: Configure launcher icons in pubspec.yaml**

At the end of `pubspec.yaml`, add:

```yaml
flutter_launcher_icons:
  image_path: "assets/images/ui/icon-placeholder.png"
  android: true
  ios: true
  remove_alpha_ios: true
  adaptive_icon_background: "#ff8c42"
  adaptive_icon_foreground: "assets/images/ui/icon-placeholder.png"

flutter_native_splash:
  color: "#ffe1c0"
  image: "assets/images/ui/icon-placeholder.png"
  android: true
  ios: true
  android_12:
    color: "#ffe1c0"
    image: "assets/images/ui/icon-placeholder.png"
```

- [ ] **Step 4: Generate icons & splash**

```bash
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```
Expected: tools generate icon and splash variants for both platforms. Check `android/app/src/main/res/mipmap-*/` and `ios/Runner/Assets.xcassets/AppIcon.appiconset/` for new files.

- [ ] **Step 5: Confirm app still builds**

```bash
flutter run --flavor development --target lib/main_development.dart
```
Expected: app launches with the orange placeholder icon and splash.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock assets/images/ui/icon-placeholder.png \
  android/app/src/main/res/ ios/Runner/
git commit -m "Add placeholder launcher icon + native splash

Uses a temporary solid orange placeholder while the style-bible fox
mascot is being generated via Nano Banana. flutter_launcher_icons and
flutter_native_splash are wired up — once the final mascot is exported
to assets/images/ui/icon.png, regenerate via:

  dart run flutter_launcher_icons
  dart run flutter_native_splash:create

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 15: README & Final Verification

**Files:**
- Modify: `README.md`

- [ ] **Step 1: Inspect VGV's generated README**

```bash
cat README.md
```
Note what's there; we'll prepend a project-specific section.

- [ ] **Step 2: Replace README.md**

Replace `README.md` with:

````markdown
# Toddler Mini-Games

Bilingual (Egyptian Arabic + English), fully offline, zero-data-collection mini-games for children aged 2+.

- [Product Requirements](docs/superpowers/specs/2026-05-11-toddler-mini-games-prd.md)
- [Design Spec](docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md)
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
  l10n/                                                             # ar + en arb files
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
````

- [ ] **Step 3: Final verification — build, test, analyze**

Run all checks one last time:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
dart run custom_lint
flutter test --exclude-tags golden
./scripts/check_forbidden_sdks.sh
./scripts/check_no_internet_permission.sh
```
Expected: every command exits with code 0. If any fails, fix before declaring Slice 0 done.

- [ ] **Step 4: Run the app on iOS sim and Android emu one final time**

```bash
flutter run --flavor development --target lib/main_development.dart -d "iPhone 15"
# Confirm: launches, shows "Home (scaffold)" page, no console errors. Quit with q.

flutter run --flavor development --target lib/main_development.dart -d emulator-5554
# Same. Quit with q.
```

- [ ] **Step 5: Commit the README**

```bash
git add README.md
git commit -m "Add project README

Covers prerequisites, first-time setup, run/test/codegen commands,
compliance checks, project structure, and a pointer to CLAUDE.md
for hard rules.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

- [ ] **Step 6: Tag the slice completion**

```bash
git tag -a slice-0-complete -m "Slice 0: scaffold + tooling complete

Empty Flutter app runs on iOS and Android with:
- Riverpod 2 + go_router routing
- Strict lint stack (very_good_analysis + custom_lint + riverpod_lint)
- Codegen pipeline (build_runner + freezed + json_serializable + riverpod_generator)
- gen-l10n localization with ar (default) + en
- Lefthook pre-commit + pre-push
- GitHub Actions CI (analyze/format/test) + compliance workflow
- AI rules (CLAUDE.md + symlinks)
- Android INTERNET permission stripped from release flavor
- iOS PrivacyInfo.xcprivacy declaring zero data collection
- Forbidden-SDK and INTERNET-permission CI guards
- Placeholder launcher icon and splash
- Folder skeleton for core/features/games
- README"
```

- [ ] **Step 7: Final inventory check**

Run:
```bash
git log --oneline | head -30
ls -la
flutter doctor
```

Verify the commit history reflects clean, atomic commits for each task. Run `flutter doctor` to confirm the dev environment has no warnings worth fixing before moving to Slice 1.

**Slice 0 is complete when:**
- ✅ App launches in dev flavor on both iOS sim and Android emu
- ✅ All tests pass (`flutter test --exclude-tags golden`)
- ✅ `flutter analyze --fatal-infos` is clean
- ✅ `dart run custom_lint` is clean
- ✅ Both compliance scripts exit 0
- ✅ CI workflows are present and well-formed (will run on first push)
- ✅ Lefthook is installed locally
- ✅ Folder skeleton matches the spec
- ✅ CLAUDE.md + symlinks are present
- ✅ Git tag `slice-0-complete` is created

---

## Self-Review

Walking the spec against this plan to confirm coverage:

- ✅ **Tech stack** (spec §9): Flutter stable + Riverpod 2 + go_router + freezed + audioplayers (deferred to Slice 2 since no audio in this slice). All present except audio.
- ✅ **Bootstrap** (spec §10.1): Very Good CLI scaffold, Bloc removed, Riverpod replaced. ✓
- ✅ **Lint stack** (spec §10.2): very_good_analysis + custom_lint + riverpod_lint. ✓
- ✅ **Codegen** (spec §10.3): build_runner + freezed + json_serializable + flutter_launcher_icons + flutter_native_splash. `riverpod_generator` is wired (Task 3 dev_deps); `go_router_builder` is also wired (Task 4 dev_deps), but no actual typed routes are generated yet because we have only two simple paths — they'll get codegen'd when we have parametric routes in Slice 1. **Note:** typed routes are not exercised in Slice 0; this is fine because routes are trivial. Slice 1 will exercise them.
- ✅ **CI + hooks** (spec §10.4): Lefthook, GitHub Actions matrix, macOS-only goldens, forbidden-SDK + INTERNET grep guards. ✓
- ✅ **AI rules** (spec §10.5): CLAUDE.md + AGENTS.md symlink + .cursorrules symlink. Content matches the conventions list in the spec. ✓
- ✅ **Kids safety guards** (spec §6 / §10.4): INTERNET strip + iOS PrivacyInfo + grep guards. ✓
- ✅ **Project structure** (spec §11): lib/{core,features,l10n}, assets/{images,audio}, art/, docs/. All present. ✓
- ⚠ **AudioService, LocaleProvider, SettingsService implementations** (spec §9.3): not in Slice 0 — these are Slice 1 work. The folders exist as placeholders. ✓ (this is by design — Slice 0 is scaffolding only)
- ⚠ **Parent gate** (spec §7.2): not in Slice 0 — Slice 1. ✓
- ⚠ **Game implementations** (spec §3): not in Slice 0 — Slices 2–6. ✓

**Placeholder scan:** searched the plan for "TBD"/"TODO"/"implement later"/"appropriate"/"handle edge cases" — none found. One mention of "TBD" appears in the README license section, which is intentional and labeled as such.

**Type/name consistency:**
- `SettingsState` class with fields `locale`, `soundEnabled`, `enabledGames`: defined in Task 6, will be used in Slice 1's settings service. ✓
- `routerProvider`: defined in Task 4, consumed in App widget (Task 4) and tests. ✓
- Folder paths `lib/core/{audio,locale,settings,gate,theme}` and `lib/features/games/{zoo,bubble_pop,shape_sorter,finger_paint,drive_vehicle}` consistent across Task 4 file structure section and Task 8 mkdir commands. ✓
- Flavor names `development`, `staging`, `production` consistent with VGV defaults and used identically in all `flutter run` and target paths. ✓

**Scope:** focused, single subsystem (scaffold + tooling). Single implementation plan. ✓

No issues found. Plan is ready for execution.

---

## Out of scope for this slice (covered in later slices)

- Audio service (`audioplayers` wrapper) — Slice 1
- Locale provider (runtime ar-EG ↔ en toggle) — Slice 1
- Settings service (persistence to shared_preferences) — Slice 1
- Parent gate (math problem) — Slice 1
- Home screen icon grid UI — Slice 1
- Settings screen UI — Slice 1
- All five game implementations — Slices 2–6
- Style-bible asset generation (Nano Banana fox + scenes) — runs in parallel with implementation; not blocking for any slice
- Voice recording / ElevenLabs production — Slice 2 (when first game needs animal names)
- Store metadata, screenshots, age questionnaires — Slice 7
- TestFlight + Play internal track upload — Slice 7

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-11-slice-0-scaffold-and-tooling.md`.

Two execution options when you (the user) are ready to start:

1. **Subagent-Driven (recommended)** — A fresh subagent runs each task, I review between tasks, fast iteration with checkpoints.
2. **Inline Execution** — Tasks run in the same session using executing-plans, with batch execution and review checkpoints.

Decision deferred until you start executing — for now, the plan stays on the shelf alongside the spec and PRD.
