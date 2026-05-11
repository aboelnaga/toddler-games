# Slice 1: App Shell — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the parent-facing chrome — theme, locale switching, persistent settings, home-screen icon grid, parent gate with math problem, and the settings screen — so that by the end of this slice the whole app shell works end-to-end with placeholder game tiles. No game logic yet.

**Architecture:** Three Riverpod-managed services in `lib/core/`:
- `SettingsService` (synchronous wrapper around `shared_preferences`) backed by the `SettingsState` model from Slice 0.
- `LocaleNotifier` (controls runtime locale, drives RTL).
- A pure-Dart `ParentGateMathProblem` generator (testable in isolation, locale-aware numeral rendering).

Three screens in `lib/features/`:
- `HomeScreen` — 2×3 icon-grid of game tiles. Disabled games render dimmed. Bottom-right gear opens the parent gate. No game logic; tiles just navigate to `/game/:id` which shows a "coming soon" placeholder.
- `ParentGateScreen` — math problem + 4 answer buttons. On success, navigates to the gated destination (settings or external link confirmation).
- `SettingsScreen` — language toggle, sound master toggle, 5 per-game enable toggles, About section (version, support email, privacy/terms links behind second-gate).

**Tech Stack additions over Slice 0:**
- `shared_preferences` (settings persistence)
- `url_launcher` (open privacy/terms in system browser, behind a parent gate)
- `flutter_animate` (small touch-feedback animations on tile press)

**Scope check:** This slice produces the full parent-facing app and a navigable home screen. Game tiles route to placeholder screens. Slice 2 turns the first tile (Zoo) into a real game.

**Companion docs:**
- [Product Requirements](../specs/2026-05-11-toddler-mini-games-prd.md)
- [Design Spec](../specs/2026-05-11-toddler-mini-games-design.md)
- [Slice 0 plan (scaffold + tooling)](./2026-05-11-slice-0-scaffold-and-tooling.md)

**Pre-conditions:** Slice 0 complete. `slice-0-complete` git tag present. Running the app shows "Home (scaffold)".

---

## File Structure (what this slice creates or modifies)

```
lib/
  core/
    theme/
      app_theme.dart                              # theme tokens (colors, radii, spacing)
      design_tokens.dart                          # raw token constants
    settings/
      settings_state.dart                         # (already exists from Slice 0)
      settings_service.dart                      # SharedPreferences wrapper
      settings_notifier.dart                     # Riverpod StateNotifier
    locale/
      locale_notifier.dart                       # Riverpod locale provider + RTL
      supported_locales.dart                     # const list of supported locales
    gate/
      parent_gate_problem.dart                   # pure math problem generator
      parent_gate_screen.dart                    # gate UI
      gate_arguments.dart                        # what to do post-success
    routing/
      router.dart                                 # (modified — add gated routes)

  features/
    home/
      home_screen.dart                            # icon grid
      game_tile.dart                              # reusable tile widget
      game_catalog.dart                           # const list of game metadata
    settings/
      settings_screen.dart                        # full settings UI
      widgets/
        language_toggle.dart
        sound_toggle.dart
        per_game_toggle_list.dart
        about_section.dart
    games/
      _placeholder/
        placeholder_game_screen.dart              # "Coming soon" stub for unfinished games

  l10n/arb/
    app_en.arb                                    # (expanded with shell strings)
    app_ar.arb                                    # (expanded with shell strings)

test/
  core/
    theme/
      app_theme_test.dart
    settings/
      settings_service_test.dart
      settings_notifier_test.dart
    locale/
      locale_notifier_test.dart
    gate/
      parent_gate_problem_test.dart
      parent_gate_screen_test.dart
  features/
    home/
      home_screen_test.dart
      game_tile_test.dart
    settings/
      settings_screen_test.dart
  goldens/
    home_screen_ar_golden_test.dart
    home_screen_en_golden_test.dart
    parent_gate_ar_golden_test.dart
    parent_gate_en_golden_test.dart
    settings_screen_ar_golden_test.dart
    settings_screen_en_golden_test.dart
```

---

## Task 1: Design Tokens & Theme

**Files:**
- Create: `lib/core/theme/design_tokens.dart`
- Create: `lib/core/theme/app_theme.dart`
- Modify: `lib/app/view/app.dart` (apply theme)
- Test: `test/core/theme/app_theme_test.dart`

- [ ] **Step 1: Create the design tokens module**

Create `lib/core/theme/design_tokens.dart`:

```dart
import 'package:flutter/material.dart';

/// Project-wide design tokens.
///
/// Reference: docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md §4
///
/// Toddler-app design rules baked in:
/// - Saturated focal colors with calm backdrops.
/// - Large touch targets (>=60dp).
/// - Generous padding and radii so visuals feel friendly, not cramped.
abstract final class DesignTokens {
  // --- Color palette (warm storybook + flat-illustrated hybrid)
  static const Color foxOrange = Color(0xFFFF8C42);
  static const Color cream = Color(0xFFFFF5E6);
  static const Color skyPeach = Color(0xFFFFE1C0);
  static const Color meadowGreen = Color(0xFFA8D895);
  static const Color blushPink = Color(0xFFFF6B9D);
  static const Color textCharcoal = Color(0xFF2A2A2A);
  static const Color textSecondary = Color(0xFF6E6E6E);
  static const Color overlayDim = Color(0x66000000);

  // --- Spacing (4dp grid)
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space5 = 24;
  static const double space6 = 32;
  static const double space7 = 48;
  static const double space8 = 64;

  // --- Radii
  static const double radiusS = 8;
  static const double radiusM = 16;
  static const double radiusL = 24;
  static const double radiusXL = 32;

  // --- Touch targets
  static const double minTouchTarget = 64; // toddler-friendly; bigger than Apple's 44
  static const double tileSize = 120;

  // --- Type sizes
  static const double fontSizeBody = 16;
  static const double fontSizeTitle = 22;
  static const double fontSizeDisplay = 36; // parent-gate math problem
}
```

- [ ] **Step 2: Create the theme module**

Create `lib/core/theme/app_theme.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: DesignTokens.foxOrange,
      surface: DesignTokens.cream,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: DesignTokens.cream,
      textTheme: const TextTheme(
        bodyMedium: TextStyle(
          fontSize: DesignTokens.fontSizeBody,
          color: DesignTokens.textCharcoal,
        ),
        titleLarge: TextStyle(
          fontSize: DesignTokens.fontSizeTitle,
          color: DesignTokens.textCharcoal,
          fontWeight: FontWeight.w600,
        ),
        displayMedium: TextStyle(
          fontSize: DesignTokens.fontSizeDisplay,
          color: DesignTokens.textCharcoal,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(DesignTokens.minTouchTarget, DesignTokens.minTouchTarget),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space5,
            vertical: DesignTokens.space3,
          ),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusL),
        ),
        elevation: 2,
      ),
    );
  }
}
```

- [ ] **Step 3: Write a smoke test for the theme**

Create `test/core/theme/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/theme/app_theme.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

void main() {
  group('AppTheme.light', () {
    test('uses fox-orange as seed and produces a Material 3 theme', () {
      final theme = AppTheme.light();
      expect(theme.useMaterial3, isTrue);
      expect(theme.scaffoldBackgroundColor, DesignTokens.cream);
      expect(theme.colorScheme.primary, isNot(equals(DesignTokens.foxOrange)));
      // primary is derived from the seed, not equal to it
      // sanity: brightness is light
      expect(theme.brightness, Brightness.light);
    });

    test('filled-button minimum size meets toddler touch target', () {
      final theme = AppTheme.light();
      final style = theme.filledButtonTheme.style!;
      final minSize = style.minimumSize?.resolve(<MaterialState>{});
      expect(minSize?.width, DesignTokens.minTouchTarget);
      expect(minSize?.height, DesignTokens.minTouchTarget);
    });
  });
}
```

- [ ] **Step 4: Run the test (should pass once the theme module compiles)**

```bash
flutter test test/core/theme/app_theme_test.dart
```
Expected: PASS.

- [ ] **Step 5: Apply the theme in `App` widget**

Edit `lib/app/view/app.dart`. Replace the `theme:` line with `AppTheme.light()`. The full file becomes:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/routing/router.dart';
import 'package:toddler_games/core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 6: Run all tests to confirm nothing regressed**

```bash
flutter test --exclude-tags golden
```
Expected: all green.

- [ ] **Step 7: Commit**

```bash
git add lib/core/theme/ test/core/theme/ lib/app/
git commit -m "Add design tokens and Material 3 theme

- DesignTokens: palette (fox orange, cream, sky peach, meadow green,
  blush pink), 4dp spacing grid, radii, touch targets, type sizes
- AppTheme.light: M3 ColorScheme seeded from fox orange, 64dp minimum
  button size, friendly rounded shapes
- Apply theme in App widget

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 2: Supported Locales

**Files:**
- Create: `lib/core/locale/supported_locales.dart`

- [ ] **Step 1: Create the supported-locales constants module**

Create `lib/core/locale/supported_locales.dart`:

```dart
import 'package:flutter/material.dart';

/// Locales the app ships in v1.
///
/// Reference: docs/superpowers/specs/2026-05-11-toddler-mini-games-design.md §6
///
/// Default locale is Egyptian Arabic. English is the toggleable secondary.
/// MSA is reserved for v2; do not add it here without a memo updating the
/// spec.
abstract final class SupportedLocales {
  static const Locale arabicEgyptian = Locale('ar', 'EG');
  static const Locale english = Locale('en');

  static const Locale defaultLocale = arabicEgyptian;

  static const List<Locale> all = <Locale>[arabicEgyptian, english];

  /// Stable string id used in stored settings (`SettingsState.locale`).
  static String idFor(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }
    return locale.languageCode;
  }

  /// Reverse of [idFor]. Returns [defaultLocale] if id is unknown.
  static Locale fromId(String id) {
    for (final l in all) {
      if (idFor(l) == id) return l;
    }
    return defaultLocale;
  }

  /// Whether the given locale should render RTL.
  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}
```

- [ ] **Step 2: Write a smoke test**

Create `test/core/locale/supported_locales_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';

void main() {
  group('SupportedLocales', () {
    test('default is ar-EG', () {
      expect(SupportedLocales.defaultLocale, const Locale('ar', 'EG'));
    });

    test('ships exactly ar-EG and en', () {
      expect(SupportedLocales.all, hasLength(2));
      expect(SupportedLocales.all, contains(const Locale('ar', 'EG')));
      expect(SupportedLocales.all, contains(const Locale('en')));
    });

    test('idFor / fromId round-trip', () {
      for (final l in SupportedLocales.all) {
        expect(SupportedLocales.fromId(SupportedLocales.idFor(l)), l);
      }
    });

    test('idFor produces ar-EG and en', () {
      expect(SupportedLocales.idFor(const Locale('ar', 'EG')), 'ar-EG');
      expect(SupportedLocales.idFor(const Locale('en')), 'en');
    });

    test('fromId falls back to default on unknown id', () {
      expect(SupportedLocales.fromId('fr'), SupportedLocales.defaultLocale);
    });

    test('isRtl is true only for ar', () {
      expect(SupportedLocales.isRtl(const Locale('ar', 'EG')), isTrue);
      expect(SupportedLocales.isRtl(const Locale('en')), isFalse);
    });
  });
}
```

- [ ] **Step 3: Run the test**

```bash
flutter test test/core/locale/supported_locales_test.dart
```
Expected: PASS.

- [ ] **Step 4: Commit**

```bash
git add lib/core/locale/ test/core/locale/
git commit -m "Add SupportedLocales constants and id helpers

Exposes the two locales the app ships in v1 (ar-EG default, en toggle),
the stable string ids used in stored settings, and the RTL predicate.
N-ready — adding a third locale (MSA, French, etc.) requires only
appending to .all.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 3: SettingsService — SharedPreferences Wrapper

**Files:**
- Modify: `pubspec.yaml` (add shared_preferences)
- Create: `lib/core/settings/settings_service.dart`
- Test: `test/core/settings/settings_service_test.dart`

- [ ] **Step 1: Add shared_preferences**

In `pubspec.yaml` `dependencies:` add:

```yaml
  shared_preferences: ^2.3.2
```

Run `flutter pub get`.

- [ ] **Step 2: Write the failing test for SettingsService**

Create `test/core/settings/settings_service_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = SettingsService(prefs);
  });

  group('SettingsService', () {
    test('returns defaults when nothing is persisted', () {
      final state = service.read();
      expect(state, const SettingsState());
      expect(state.locale, 'ar-EG');
      expect(state.soundEnabled, isTrue);
      expect(state.enabledGames, hasLength(5));
    });

    test('writes and reads back a modified state', () async {
      const updated = SettingsState(
        locale: 'en',
        soundEnabled: false,
        enabledGames: <String>['zoo', 'shape_sorter'],
      );
      await service.write(updated);

      final read = service.read();
      expect(read, updated);
    });

    test('persisted state survives a re-instantiation', () async {
      const updated = SettingsState(locale: 'en');
      await service.write(updated);

      final fresh = SettingsService(prefs);
      expect(fresh.read().locale, 'en');
    });

    test('falls back to defaults on corrupted JSON', () async {
      await prefs.setString('settings_v1', '{not valid json');
      final read = service.read();
      expect(read, const SettingsState());
    });
  });
}
```

- [ ] **Step 3: Run the test (should fail — service doesn't exist)**

```bash
flutter test test/core/settings/settings_service_test.dart
```
Expected: FAIL with import error.

- [ ] **Step 4: Implement SettingsService**

Create `lib/core/settings/settings_service.dart`:

```dart
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

/// Synchronous read / async write wrapper around SharedPreferences for the
/// app's settings.
///
/// We persist the entire SettingsState as a single JSON string under a
/// versioned key so future schema migrations are explicit (`settings_v1`
/// → `settings_v2`).
class SettingsService {
  SettingsService(this._prefs);

  static const _key = 'settings_v1';
  final SharedPreferences _prefs;

  SettingsState read() {
    final raw = _prefs.getString(_key);
    if (raw == null) return const SettingsState();
    try {
      final json = jsonDecode(raw) as Map<String, Object?>;
      return SettingsState.fromJson(json);
    } catch (e, st) {
      developer.log(
        'Settings JSON corrupted; falling back to defaults',
        error: e,
        stackTrace: st,
      );
      return const SettingsState();
    }
  }

  Future<void> write(SettingsState state) async {
    await _prefs.setString(_key, jsonEncode(state.toJson()));
  }
}
```

- [ ] **Step 5: Run the test**

```bash
flutter test test/core/settings/settings_service_test.dart
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/core/settings/settings_service.dart \
  test/core/settings/settings_service_test.dart
git commit -m "Add SettingsService over SharedPreferences

- Single versioned key (settings_v1) stores the full SettingsState as JSON
- Synchronous read for fast app startup
- Async write
- Corrupted-JSON fallback to defaults
- Tested with mocked SharedPreferences

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 4: SettingsNotifier — Riverpod State

**Files:**
- Create: `lib/core/settings/settings_notifier.dart`
- Modify: `lib/bootstrap.dart` (initialize SharedPreferences before runApp)
- Test: `test/core/settings/settings_notifier_test.dart`

- [ ] **Step 1: Update bootstrap to initialize SharedPreferences and override the provider**

Edit `lib/bootstrap.dart` to look like:

```dart
import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';

Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  final prefs = await SharedPreferences.getInstance();
  final settingsService = SettingsService(prefs);

  runApp(
    ProviderScope(
      overrides: [
        settingsServiceProvider.overrideWithValue(settingsService),
      ],
      child: await builder(),
    ),
  );
}
```

- [ ] **Step 2: Write the failing test for SettingsNotifier**

Create `test/core/settings/settings_notifier_test.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

void main() {
  late SharedPreferences prefs;
  late SettingsService service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    service = SettingsService(prefs);
    container = ProviderContainer(
      overrides: [settingsServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);
  });

  group('SettingsNotifier', () {
    test('initial state is the service default', () {
      final state = container.read(settingsProvider);
      expect(state, const SettingsState());
    });

    test('setLocale updates state and persists', () async {
      await container.read(settingsProvider.notifier).setLocale('en');
      expect(container.read(settingsProvider).locale, 'en');
      // and persisted
      expect(service.read().locale, 'en');
    });

    test('setSoundEnabled updates state and persists', () async {
      await container.read(settingsProvider.notifier).setSoundEnabled(false);
      expect(container.read(settingsProvider).soundEnabled, isFalse);
      expect(service.read().soundEnabled, isFalse);
    });

    test('toggleGameEnabled flips per-game enable state', () async {
      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      // zoo started enabled, so toggle removes it
      expect(container.read(settingsProvider).enabledGames, isNot(contains('zoo')));

      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      expect(container.read(settingsProvider).enabledGames, contains('zoo'));
    });
  });
}
```

- [ ] **Step 3: Run the test (should fail)**

```bash
flutter test test/core/settings/settings_notifier_test.dart
```
Expected: FAIL (provider doesn't exist).

- [ ] **Step 4: Implement SettingsNotifier**

Create `lib/core/settings/settings_notifier.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/settings/settings_state.dart';

/// Provider for [SettingsService]. Overridden in bootstrap with the
/// real instance backed by SharedPreferences.
final settingsServiceProvider = Provider<SettingsService>((ref) {
  throw UnimplementedError('Override settingsServiceProvider in bootstrap');
});

/// The current settings state. Mutations go through the notifier; widgets
/// watch this provider for reactive rebuilds.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final service = ref.watch(settingsServiceProvider);
  return SettingsNotifier(service);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._service) : super(_service.read());

  final SettingsService _service;

  Future<void> setLocale(String locale) async {
    state = state.copyWith(locale: locale);
    await _service.write(state);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _service.write(state);
  }

  Future<void> toggleGameEnabled(String gameId) async {
    final games = [...state.enabledGames];
    if (games.contains(gameId)) {
      games.remove(gameId);
    } else {
      games.add(gameId);
    }
    state = state.copyWith(enabledGames: games);
    await _service.write(state);
  }
}
```

- [ ] **Step 5: Run the test**

```bash
flutter test test/core/settings/settings_notifier_test.dart
```
Expected: PASS.

- [ ] **Step 6: Verify the broader suite still passes**

```bash
flutter test --exclude-tags golden
flutter analyze --fatal-infos
dart run custom_lint
```
Expected: clean.

- [ ] **Step 7: Commit**

```bash
git add lib/bootstrap.dart lib/core/settings/settings_notifier.dart \
  test/core/settings/settings_notifier_test.dart
git commit -m "Add SettingsNotifier (Riverpod) and bootstrap initialization

- settingsServiceProvider: overridden in bootstrap with a SharedPreferences-
  backed SettingsService
- settingsProvider: StateNotifierProvider exposing SettingsState
- Methods: setLocale, setSoundEnabled, toggleGameEnabled
- Each mutation persists immediately
- Tested in isolation with mocked SharedPreferences

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 5: LocaleNotifier & RTL Handling

**Files:**
- Create: `lib/core/locale/locale_notifier.dart`
- Modify: `lib/app/view/app.dart` (watch locale, apply to MaterialApp)
- Test: `test/core/locale/locale_notifier_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/locale/locale_notifier_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/locale/locale_notifier.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('localeProvider', () {
    test('derives ar-EG by default', () {
      final locale = container.read(localeProvider);
      expect(locale, const Locale('ar', 'EG'));
    });

    test('reflects settings changes', () async {
      await container.read(settingsProvider.notifier).setLocale('en');
      final locale = container.read(localeProvider);
      expect(locale, const Locale('en'));
    });

    test('falls back to default for unknown locale id', () async {
      await container.read(settingsProvider.notifier).setLocale('fr');
      final locale = container.read(localeProvider);
      expect(locale, SupportedLocales.defaultLocale);
    });
  });
}
```

- [ ] **Step 2: Run the test (should fail)**

```bash
flutter test test/core/locale/locale_notifier_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement the locale provider**

Create `lib/core/locale/locale_notifier.dart`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';

/// Derived locale, computed from the current settings state.
///
/// Widgets that need to react to locale changes watch this provider.
/// `MaterialApp.router(locale: ref.watch(localeProvider))` drives runtime
/// locale switching.
final localeProvider = Provider<Locale>((ref) {
  final id = ref.watch(settingsProvider.select((s) => s.locale));
  return SupportedLocales.fromId(id);
});
```

- [ ] **Step 4: Run the test**

```bash
flutter test test/core/locale/locale_notifier_test.dart
```
Expected: PASS.

- [ ] **Step 5: Wire the locale into MaterialApp**

Edit `lib/app/view/app.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/locale/locale_notifier.dart';
import 'package:toddler_games/core/routing/router.dart';
import 'package:toddler_games/core/theme/app_theme.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      routerConfig: router,
    );
  }
}
```

- [ ] **Step 6: Update the app smoke test for the new ProviderScope override**

Edit `test/app/app_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/app/app.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';

void main() {
  group('App', () {
    testWidgets('boots into HomeScreen', (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
          ],
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home (scaffold)'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 7: Run all tests**

```bash
flutter test --exclude-tags golden
```
Expected: PASS.

- [ ] **Step 8: Commit**

```bash
git add lib/core/locale/locale_notifier.dart lib/app/ test/app/ \
  test/core/locale/locale_notifier_test.dart
git commit -m "Add localeProvider derived from settings; wire into MaterialApp

- localeProvider: Provider<Locale> computed from settings.locale id
- Unknown ids fall back to default (ar-EG)
- MaterialApp.router consumes locale → drives RTL via Flutter's built-in
  Directionality
- App smoke test updated to provide SharedPreferences override

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 6: Localization Strings for the Shell

**Files:**
- Modify: `lib/l10n/arb/app_en.arb` (expand)
- Modify: `lib/l10n/arb/app_ar.arb` (expand)

- [ ] **Step 1: Define all shell strings in `app_en.arb`**

Replace `lib/l10n/arb/app_en.arb`:

```json
{
  "@@locale": "en",
  "appTitle": "Toddler Games",
  "@appTitle": {},

  "homeTitle": "Home",
  "settingsTitle": "Settings",
  "settingsForGrownUps": "For Grown-Ups",
  "@settingsForGrownUps": {
    "description": "Header on parent gate and settings"
  },

  "parentGatePrompt": "What is {a} + {b} = ?",
  "@parentGatePrompt": {
    "placeholders": {
      "a": {"type": "int"},
      "b": {"type": "int"}
    }
  },
  "parentGateHelp": "Tap the answer",

  "settingsLanguage": "Language",
  "settingsLanguageArabic": "Egyptian Arabic",
  "settingsLanguageEnglish": "English",

  "settingsSound": "Sound",
  "settingsSoundOn": "On",
  "settingsSoundOff": "Off",

  "settingsGames": "Games",
  "settingsGameZoo": "Zoo",
  "settingsGameBubblePop": "Bubble Pop",
  "settingsGameShapeSorter": "Shape Sorter",
  "settingsGameFingerPaint": "Finger Paint",
  "settingsGameDriveVehicle": "Drive",

  "settingsAbout": "About",
  "settingsVersion": "Version {version}",
  "@settingsVersion": {
    "placeholders": {"version": {"type": "String"}}
  },
  "settingsSupportEmail": "Support",
  "settingsPrivacyPolicy": "Privacy Policy",
  "settingsTerms": "Terms",

  "placeholderGameMessage": "This game is coming soon."
}
```

- [ ] **Step 2: Define matching strings in `app_ar.arb`**

Replace `lib/l10n/arb/app_ar.arb`:

```json
{
  "@@locale": "ar",
  "appTitle": "ألعاب الأطفال",

  "homeTitle": "الرئيسية",
  "settingsTitle": "الإعدادات",
  "settingsForGrownUps": "للكبار",

  "parentGatePrompt": "{a} + {b} = ؟",
  "parentGateHelp": "اضغط على الإجابة",

  "settingsLanguage": "اللغة",
  "settingsLanguageArabic": "العربية المصرية",
  "settingsLanguageEnglish": "إنجليزي",

  "settingsSound": "الصوت",
  "settingsSoundOn": "مفعل",
  "settingsSoundOff": "مغلق",

  "settingsGames": "الألعاب",
  "settingsGameZoo": "حديقة الحيوان",
  "settingsGameBubblePop": "الفقاعات",
  "settingsGameShapeSorter": "الأشكال",
  "settingsGameFingerPaint": "الرسم",
  "settingsGameDriveVehicle": "العربية",

  "settingsAbout": "عن التطبيق",
  "settingsVersion": "النسخة {version}",
  "settingsSupportEmail": "الدعم",
  "settingsPrivacyPolicy": "سياسة الخصوصية",
  "settingsTerms": "الشروط",

  "placeholderGameMessage": "اللعبة دي هتيجي قريب"
}
```

- [ ] **Step 3: Regenerate**

```bash
flutter gen-l10n
flutter analyze
```
Expected: clean.

- [ ] **Step 4: Commit**

```bash
git add lib/l10n/arb/
git commit -m "Expand l10n strings for the app shell

Adds parent-gate, settings sections (language, sound, per-game,
about), placeholder game message, and version label. Egyptian
Arabic uses colloquial vocabulary (حديقة الحيوان, العربية, etc.)
rather than MSA.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 7: Math Problem Generator (Pure Function)

**Files:**
- Create: `lib/core/gate/parent_gate_problem.dart`
- Test: `test/core/gate/parent_gate_problem_test.dart`

- [ ] **Step 1: Write the failing test**

Create `test/core/gate/parent_gate_problem_test.dart`:

```dart
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';

void main() {
  group('ParentGateProblem', () {
    test('addends are between 1 and 9 inclusive', () {
      final rng = Random(42);
      for (var i = 0; i < 100; i++) {
        final p = ParentGateProblem.generate(rng);
        expect(p.a, inInclusiveRange(1, 9));
        expect(p.b, inInclusiveRange(1, 9));
      }
    });

    test('correctAnswer equals a + b', () {
      final rng = Random(42);
      for (var i = 0; i < 50; i++) {
        final p = ParentGateProblem.generate(rng);
        expect(p.correctAnswer, p.a + p.b);
      }
    });

    test('choices contains exactly 4 unique values including the correct one', () {
      final rng = Random(42);
      for (var i = 0; i < 50; i++) {
        final p = ParentGateProblem.generate(rng);
        expect(p.choices, hasLength(4));
        expect(p.choices.toSet(), hasLength(4));
        expect(p.choices, contains(p.correctAnswer));
      }
    });

    test('isCorrect returns true only for the right answer', () {
      final rng = Random(42);
      final p = ParentGateProblem.generate(rng);
      expect(p.isCorrect(p.correctAnswer), isTrue);
      for (final c in p.choices.where((c) => c != p.correctAnswer)) {
        expect(p.isCorrect(c), isFalse);
      }
    });

    test('formatNumber renders Arabic-Indic numerals when locale is ar', () {
      expect(ParentGateProblem.formatNumber(7, 'ar-EG'), '٧');
      expect(ParentGateProblem.formatNumber(10, 'ar-EG'), '١٠');
    });

    test('formatNumber renders Western numerals when locale is en', () {
      expect(ParentGateProblem.formatNumber(7, 'en'), '7');
      expect(ParentGateProblem.formatNumber(10, 'en'), '10');
    });
  });
}
```

- [ ] **Step 2: Run the test (should fail)**

```bash
flutter test test/core/gate/parent_gate_problem_test.dart
```
Expected: FAIL.

- [ ] **Step 3: Implement the generator**

Create `lib/core/gate/parent_gate_problem.dart`:

```dart
import 'dart:math';

/// A parent-gate addition problem.
///
/// Single-digit addends (1..9 inclusive). Four answer choices including
/// the correct one. Locale-aware numeral rendering.
class ParentGateProblem {
  ParentGateProblem({
    required this.a,
    required this.b,
    required this.choices,
  });

  final int a;
  final int b;
  final List<int> choices;

  int get correctAnswer => a + b;

  bool isCorrect(int choice) => choice == correctAnswer;

  /// Generate a fresh problem.
  ///
  /// [rng] is exposed for testability; production code calls
  /// `ParentGateProblem.generate(Random())`.
  factory ParentGateProblem.generate(Random rng) {
    final a = 1 + rng.nextInt(9); // 1..9
    final b = 1 + rng.nextInt(9);
    final correct = a + b;
    final choices = <int>{correct};
    while (choices.length < 4) {
      // distractors within +/- 5 of correct, clamped to >= 1
      final candidate = correct + rng.nextInt(11) - 5;
      if (candidate >= 1 && candidate != correct) {
        choices.add(candidate);
      }
    }
    final list = choices.toList()..shuffle(rng);
    return ParentGateProblem(a: a, b: b, choices: list);
  }

  /// Render an integer in the numeral set for [localeId].
  ///
  /// `ar-EG` → Arabic-Indic (٠–٩). Anything else → Western (0–9).
  static String formatNumber(int n, String localeId) {
    final western = n.toString();
    if (!localeId.startsWith('ar')) return western;
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final sb = StringBuffer();
    for (final ch in western.runes) {
      final digit = ch - 0x30; // ASCII '0' = 0x30
      if (digit >= 0 && digit <= 9) {
        sb.write(arabicDigits[digit]);
      } else {
        sb.writeCharCode(ch);
      }
    }
    return sb.toString();
  }
}
```

- [ ] **Step 4: Run the test**

```bash
flutter test test/core/gate/parent_gate_problem_test.dart
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/core/gate/parent_gate_problem.dart test/core/gate/parent_gate_problem_test.dart
git commit -m "Add ParentGateProblem (pure math problem generator)

- Single-digit addends, 4 unique choices including the correct one
- Distractors within +/- 5 of correct, clamped to positive
- Locale-aware numeral rendering: Arabic-Indic for ar, Western otherwise
- Pure Dart, fully testable with seeded Random

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 8: Parent Gate Screen

**Files:**
- Create: `lib/core/gate/parent_gate_screen.dart`
- Create: `lib/core/gate/gate_arguments.dart` (what happens on success)
- Test: `test/core/gate/parent_gate_screen_test.dart`

- [ ] **Step 1: Define gate arguments / success callback**

Create `lib/core/gate/gate_arguments.dart`:

```dart
/// What the parent gate should navigate to on success.
///
/// Encoded as a string so it's safe to pass through go_router state.
enum GateDestination {
  settings,
  privacyPolicy,
  terms;

  static GateDestination fromString(String? raw) {
    return GateDestination.values.firstWhere(
      (d) => d.name == raw,
      orElse: () => GateDestination.settings,
    );
  }
}
```

- [ ] **Step 2: Write the widget test**

Create `test/core/gate/parent_gate_screen_test.dart`:

```dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';

void main() {
  Widget wrap(Widget child, {Locale locale = const Locale('en')}) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: ProviderScope(child: child),
    );
  }

  group('ParentGateScreen', () {
    testWidgets('renders the problem text + 4 choice buttons', (tester) async {
      // Deterministic problem (7 + 3 = 10)
      final problem = ParentGateProblem(
        a: 7,
        b: 3,
        choices: [8, 10, 12, 15],
      );

      var success = false;
      await tester.pumpWidget(wrap(
        ParentGateScreen(
          problem: problem,
          localeId: 'en',
          onSuccess: () => success = true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('What is 7 + 3 = ?'), findsOneWidget);
      // 4 choice buttons
      expect(find.byType(FilledButton), findsNWidgets(4));
      // success not fired yet
      expect(success, isFalse);
    });

    testWidgets('calls onSuccess when correct choice tapped', (tester) async {
      final problem = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
      var success = false;
      await tester.pumpWidget(wrap(
        ParentGateScreen(
          problem: problem,
          localeId: 'en',
          onSuccess: () => success = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      expect(success, isTrue);
    });

    testWidgets('does NOT call onSuccess when wrong choice tapped — regenerates problem', (tester) async {
      var generated = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
      var success = false;
      late StateSetter setter;
      await tester.pumpWidget(wrap(
        StatefulBuilder(builder: (context, set) {
          setter = set;
          return ParentGateScreen(
            problem: generated,
            localeId: 'en',
            onSuccess: () => success = true,
            onWrongAnswer: () {
              setter(() {
                generated = ParentGateProblem(a: 4, b: 2, choices: [3, 6, 8, 9]);
              });
            },
          );
        }),
      ));
      await tester.pumpAndSettle();

      // Tap wrong answer
      await tester.tap(find.text('8'));
      await tester.pumpAndSettle();

      expect(success, isFalse);
      // The problem regenerated, so we now see "4 + 2"
      expect(find.text('What is 4 + 2 = ?'), findsOneWidget);
    });

    testWidgets('renders Arabic-Indic numerals when locale is ar', (tester) async {
      final problem = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);
      await tester.pumpWidget(wrap(
        ParentGateScreen(
          problem: problem,
          localeId: 'ar-EG',
          onSuccess: () {},
        ),
        locale: const Locale('ar', 'EG'),
      ));
      await tester.pumpAndSettle();

      // Match the localized prompt — Arabic prompt is "7 + 3 = ?" using
      // Arabic numerals
      expect(find.text('٧ + ٣ = ؟'), findsOneWidget);
      expect(find.text('١٠'), findsOneWidget);
    });
  });
}
```

- [ ] **Step 3: Run the test (should fail)**

```bash
flutter test test/core/gate/parent_gate_screen_test.dart
```
Expected: FAIL.

- [ ] **Step 4: Implement ParentGateScreen**

Create `lib/core/gate/parent_gate_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

class ParentGateScreen extends StatelessWidget {
  const ParentGateScreen({
    required this.problem,
    required this.localeId,
    required this.onSuccess,
    this.onWrongAnswer,
    super.key,
  });

  final ParentGateProblem problem;
  final String localeId;
  final VoidCallback onSuccess;
  final VoidCallback? onWrongAnswer;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final a = ParentGateProblem.formatNumber(problem.a, localeId);
    final b = ParentGateProblem.formatNumber(problem.b, localeId);

    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(DesignTokens.space5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l.settingsForGrownUps,
                  style: TextStyle(
                    fontSize: DesignTokens.fontSizeBody,
                    color: DesignTokens.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: DesignTokens.space5),
                Text(
                  l.parentGatePrompt(problem.a, problem.b)
                      .replaceAll(problem.a.toString(), a)
                      .replaceAll(problem.b.toString(), b),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: DesignTokens.space6),
                Wrap(
                  spacing: DesignTokens.space3,
                  runSpacing: DesignTokens.space3,
                  alignment: WrapAlignment.center,
                  children: problem.choices
                      .map((c) => FilledButton(
                            onPressed: () {
                              if (problem.isCorrect(c)) {
                                onSuccess();
                              } else {
                                onWrongAnswer?.call();
                              }
                            },
                            child: Text(
                              ParentGateProblem.formatNumber(c, localeId),
                              style: const TextStyle(
                                fontSize: DesignTokens.fontSizeTitle,
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  l.parentGateHelp,
                  style: TextStyle(
                    color: DesignTokens.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the test**

```bash
flutter test test/core/gate/parent_gate_screen_test.dart
```
Expected: PASS. If the localized string interpolation looks wrong (e.g., when Arabic numerals don't match the format string), inspect the rendered text and adjust the prompt substitution logic.

- [ ] **Step 6: Commit**

```bash
git add lib/core/gate/ test/core/gate/parent_gate_screen_test.dart
git commit -m "Add ParentGateScreen widget

- Shows 'For Grown-Ups' header, math problem, 4 choice buttons
- onSuccess called on correct answer
- onWrongAnswer callback fires on wrong answer (caller regenerates problem)
- Locale-aware numeral rendering (Arabic-Indic when ar-EG active)
- Friendly warm-cream background, theme-driven buttons
- Tested in both en and ar-EG locales

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 9: Game Catalog & Tile Widget

**Files:**
- Create: `lib/features/home/game_catalog.dart`
- Create: `lib/features/home/game_tile.dart`
- Test: `test/features/home/game_tile_test.dart`

- [ ] **Step 1: Define the game catalog**

Create `lib/features/home/game_catalog.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

/// Static metadata for the 5 v1 games.
///
/// Each game's actual implementation lives under `lib/features/games/<id>/`.
/// This catalog is the source of truth for what shows up on the home grid
/// and in the settings per-game toggle list.
class GameCatalogEntry {
  const GameCatalogEntry({
    required this.id,
    required this.tileColor,
    required this.placeholderEmoji,
    required this.titleResolver,
  });

  final String id;
  final Color tileColor;
  final String placeholderEmoji; // shown until real art lands
  final String Function(AppLocalizations l) titleResolver;
}

abstract final class GameCatalog {
  static const List<GameCatalogEntry> all = <GameCatalogEntry>[
    GameCatalogEntry(
      id: 'zoo',
      tileColor: DesignTokens.foxOrange,
      placeholderEmoji: '🦊',
      titleResolver: _zooTitle,
    ),
    GameCatalogEntry(
      id: 'bubble_pop',
      tileColor: Color(0xFF9BF6FF),
      placeholderEmoji: '🫧',
      titleResolver: _bubbleTitle,
    ),
    GameCatalogEntry(
      id: 'shape_sorter',
      tileColor: DesignTokens.meadowGreen,
      placeholderEmoji: '⭐',
      titleResolver: _shapeTitle,
    ),
    GameCatalogEntry(
      id: 'finger_paint',
      tileColor: Color(0xFFFDFFB6),
      placeholderEmoji: '🖌️',
      titleResolver: _paintTitle,
    ),
    GameCatalogEntry(
      id: 'drive_vehicle',
      tileColor: Color(0xFFFFC6FF),
      placeholderEmoji: '🚗',
      titleResolver: _driveTitle,
    ),
  ];

  static String _zooTitle(AppLocalizations l) => l.settingsGameZoo;
  static String _bubbleTitle(AppLocalizations l) => l.settingsGameBubblePop;
  static String _shapeTitle(AppLocalizations l) => l.settingsGameShapeSorter;
  static String _paintTitle(AppLocalizations l) => l.settingsGameFingerPaint;
  static String _driveTitle(AppLocalizations l) => l.settingsGameDriveVehicle;
}
```

- [ ] **Step 2: Write the failing test for GameTile**

Create `test/features/home/game_tile_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/home/game_catalog.dart';
import 'package:toddler_games/features/home/game_tile.dart';

Widget wrap(Widget child) => MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );

void main() {
  final zoo = GameCatalog.all.first;

  group('GameTile', () {
    testWidgets('renders emoji + title when enabled', (tester) async {
      await tester.pumpWidget(wrap(GameTile(
        entry: zoo,
        enabled: true,
        onTap: () {},
      )));
      await tester.pumpAndSettle();
      expect(find.text('🦊'), findsOneWidget);
      expect(find.text('Zoo'), findsOneWidget);
    });

    testWidgets('shows lock icon and ignores tap when disabled', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(GameTile(
        entry: zoo,
        enabled: false,
        onTap: () => tapped = true,
      )));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsOneWidget);
      await tester.tap(find.byType(GameTile));
      await tester.pumpAndSettle();
      expect(tapped, isFalse);
    });

    testWidgets('invokes onTap when enabled and tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(GameTile(
        entry: zoo,
        enabled: true,
        onTap: () => tapped = true,
      )));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(GameTile));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });
}
```

- [ ] **Step 3: Run the test (should fail)**

```bash
flutter test test/features/home/game_tile_test.dart
```
Expected: FAIL.

- [ ] **Step 4: Implement GameTile**

Create `lib/features/home/game_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/home/game_catalog.dart';

class GameTile extends StatelessWidget {
  const GameTile({
    required this.entry,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final GameCatalogEntry entry;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dim = !enabled;
    return Semantics(
      label: entry.titleResolver(l),
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dim ? 0.35 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: entry.tileColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: dim
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 4),
                        blurRadius: 12,
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Text(
                    entry.placeholderEmoji,
                    style: const TextStyle(fontSize: 56),
                  ),
                ),
                Positioned(
                  bottom: DesignTokens.space2,
                  left: 0,
                  right: 0,
                  child: Text(
                    entry.titleResolver(l),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: DesignTokens.textCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (dim)
                  const Positioned(
                    top: DesignTokens.space2,
                    right: DesignTokens.space2,
                    child: Icon(Icons.lock, size: 20, color: Colors.black54),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 5: Run the test**

```bash
flutter test test/features/home/game_tile_test.dart
```
Expected: PASS.

- [ ] **Step 6: Commit**

```bash
git add lib/features/home/game_catalog.dart lib/features/home/game_tile.dart \
  test/features/home/game_tile_test.dart
git commit -m "Add GameCatalog and GameTile widget

- GameCatalog: static metadata for all 5 v1 games (id, tile color,
  placeholder emoji, localized title resolver)
- GameTile: reusable tile widget with enabled/disabled states (lock
  icon + dimmed when disabled), accessibility labels, soft shadow

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 10: Home Screen — Real Icon Grid

**Files:**
- Modify: `lib/features/home/home_screen.dart`
- Modify: `lib/core/routing/router.dart` (add gated /settings entry + /game/:id)
- Create: `lib/features/games/_placeholder/placeholder_game_screen.dart`
- Test: `test/features/home/home_screen_test.dart`

- [ ] **Step 1: Create the placeholder game screen**

Create `lib/features/games/_placeholder/placeholder_game_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

class PlaceholderGameScreen extends StatelessWidget {
  const PlaceholderGameScreen({required this.gameId, super.key});
  final String gameId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: DesignTokens.space2,
              left: DesignTokens.space2,
              child: IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.home_rounded, size: 32),
                tooltip: 'Home',
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(DesignTokens.space5),
                child: Text(
                  l.placeholderGameMessage,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Update the router**

Replace `lib/core/routing/router.dart`:

```dart
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/gate/gate_arguments.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/features/games/_placeholder/placeholder_game_screen.dart';
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
        path: '/game/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PlaceholderGameScreen(gameId: id);
        },
      ),
      GoRoute(
        path: '/parent-gate',
        builder: (context, state) {
          final destinationRaw = state.uri.queryParameters['dest'];
          final destination = GateDestination.fromString(destinationRaw);
          final problem = ParentGateProblem.generate(Random());
          final locale = ref.read(settingsProvider).locale;
          return _ParentGateRoute(
            initialProblem: problem,
            localeId: locale,
            destination: destination,
          );
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
});

class _ParentGateRoute extends StatefulWidget {
  const _ParentGateRoute({
    required this.initialProblem,
    required this.localeId,
    required this.destination,
  });

  final ParentGateProblem initialProblem;
  final String localeId;
  final GateDestination destination;

  @override
  State<_ParentGateRoute> createState() => _ParentGateRouteState();
}

class _ParentGateRouteState extends State<_ParentGateRoute> {
  late ParentGateProblem _problem = widget.initialProblem;

  @override
  Widget build(BuildContext context) {
    return ParentGateScreen(
      problem: _problem,
      localeId: widget.localeId,
      onSuccess: () {
        switch (widget.destination) {
          case GateDestination.settings:
            GoRouter.of(context).go('/settings');
          case GateDestination.privacyPolicy:
            // Handled in settings screen (external launch) — not a route.
            GoRouter.of(context).go('/settings');
          case GateDestination.terms:
            GoRouter.of(context).go('/settings');
        }
      },
      onWrongAnswer: () {
        setState(() {
          _problem = ParentGateProblem.generate(Random());
        });
      },
    );
  }
}
```

- [ ] **Step 3: Write the home screen test**

Create `test/features/home/home_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/home/game_tile.dart';
import 'package:toddler_games/features/home/home_screen.dart';

Widget wrap(Widget child, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, __) => child)],
      ),
    ),
  );
}

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('HomeScreen', () {
    testWidgets('renders 5 GameTiles', (tester) async {
      await tester.pumpWidget(
        wrap(const HomeScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byType(GameTile), findsNWidgets(5));
    });

    testWidgets('renders the gear icon (parent-gate entry)', (tester) async {
      await tester.pumpWidget(
        wrap(const HomeScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.settings_rounded), findsOneWidget);
    });

    testWidgets('disabled game tile dims and shows lock', (tester) async {
      await container.read(settingsProvider.notifier).toggleGameEnabled('zoo');
      await tester.pumpWidget(
        wrap(const HomeScreen(), container: container),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.lock), findsOneWidget);
    });
  });
}
```

- [ ] **Step 4: Run the test (should fail — HomeScreen needs the real impl)**

```bash
flutter test test/features/home/home_screen_test.dart
```
Expected: FAIL.

- [ ] **Step 5: Implement HomeScreen**

Replace `lib/features/home/home_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/home/game_catalog.dart';
import 'package:toddler_games/features/home/game_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabledGames = ref.watch(
      settingsProvider.select((s) => s.enabledGames),
    );

    return Scaffold(
      backgroundColor: DesignTokens.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(DesignTokens.space4),
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                flex: 6,
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: DesignTokens.space3,
                    crossAxisSpacing: DesignTokens.space3,
                    childAspectRatio: 1,
                  ),
                  itemCount: GameCatalog.all.length,
                  itemBuilder: (context, index) {
                    final entry = GameCatalog.all[index];
                    final enabled = enabledGames.contains(entry.id);
                    return GameTile(
                      entry: entry,
                      enabled: enabled,
                      onTap: () => context.go('/game/${entry.id}'),
                    );
                  },
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    onPressed: () =>
                        context.go('/parent-gate?dest=settings'),
                    icon: const Icon(
                      Icons.settings_rounded,
                      size: 28,
                      color: DesignTokens.textSecondary,
                    ),
                    tooltip: 'Settings',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 6: Run the test**

```bash
flutter test test/features/home/home_screen_test.dart
flutter test --exclude-tags golden
```
Expected: all green.

- [ ] **Step 7: Run the app to verify visually**

```bash
flutter run --flavor development --target lib/main_development.dart
```
Confirm: 5 colored tiles in a grid, gear icon bottom-right. Tap a tile → "This game is coming soon" placeholder. Tap home → back to grid. Tap gear → parent gate → enter correct answer → settings (next task).

- [ ] **Step 8: Commit**

```bash
git add lib/ test/features/home/home_screen_test.dart
git commit -m "Add real HomeScreen with icon grid + game-routing + gear entry

- 5 GameTiles in a 3-col grid
- Each tile routes to /game/<id> (placeholder screen for now)
- Bottom-right gear opens /parent-gate?dest=settings
- Disabled games render dimmed with a lock icon
- Reads enabled-games list from settingsProvider
- Placeholder game screen with home-return button (renders for any /game/:id)
- Router updated: /game/:id, /parent-gate, /settings now wired

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 11: Settings Screen — Language, Sound, Per-Game, About

**Files:**
- Create: `lib/features/settings/widgets/language_toggle.dart`
- Create: `lib/features/settings/widgets/sound_toggle.dart`
- Create: `lib/features/settings/widgets/per_game_toggle_list.dart`
- Create: `lib/features/settings/widgets/about_section.dart`
- Modify: `lib/features/settings/settings_screen.dart`
- Modify: `pubspec.yaml` (add url_launcher + package_info_plus)
- Test: `test/features/settings/settings_screen_test.dart`

- [ ] **Step 1: Add `url_launcher` and `package_info_plus`**

In `pubspec.yaml` `dependencies:` add:

```yaml
  url_launcher: ^6.3.0
  package_info_plus: ^8.0.2
```

Run `flutter pub get`.

- [ ] **Step 2: Create LanguageToggle**

Create `lib/features/settings/widgets/language_toggle.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final current = ref.watch(settingsProvider.select((s) => s.locale));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
          child: Text(l.settingsLanguage,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: DesignTokens.space2),
        SegmentedButton<String>(
          segments: <ButtonSegment<String>>[
            ButtonSegment(value: 'ar-EG', label: Text(l.settingsLanguageArabic)),
            ButtonSegment(value: 'en', label: Text(l.settingsLanguageEnglish)),
          ],
          selected: {current},
          onSelectionChanged: (selection) {
            ref.read(settingsProvider.notifier).setLocale(selection.first);
          },
        ),
      ],
    );
  }
}
```

- [ ] **Step 3: Create SoundToggle**

Create `lib/features/settings/widgets/sound_toggle.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';

class SoundToggle extends ConsumerWidget {
  const SoundToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final enabled = ref.watch(settingsProvider.select((s) => s.soundEnabled));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
      child: Row(
        children: [
          Expanded(
            child: Text(l.settingsSound,
                style: Theme.of(context).textTheme.titleLarge),
          ),
          Switch(
            value: enabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSoundEnabled(v),
          ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Create PerGameToggleList**

Create `lib/features/settings/widgets/per_game_toggle_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/home/game_catalog.dart';

class PerGameToggleList extends ConsumerWidget {
  const PerGameToggleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context)!;
    final enabled = ref.watch(settingsProvider.select((s) => s.enabledGames));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
          child: Text(l.settingsGames,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: DesignTokens.space2),
        ...GameCatalog.all.map((entry) => SwitchListTile(
              title: Text(entry.titleResolver(l)),
              secondary: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: entry.tileColor,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusS),
                ),
                child: Center(
                  child: Text(entry.placeholderEmoji,
                      style: const TextStyle(fontSize: 22)),
                ),
              ),
              value: enabled.contains(entry.id),
              onChanged: (_) => ref
                  .read(settingsProvider.notifier)
                  .toggleGameEnabled(entry.id),
            )),
      ],
    );
  }
}
```

- [ ] **Step 5: Create AboutSection**

Create `lib/features/settings/widgets/about_section.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutSection extends StatelessWidget {
  const AboutSection({super.key});

  // TODO(slice-7): replace placeholders with real GitHub Pages URLs and
  // support email before store submission.
  static const _privacyUrl = 'https://aboelnaga.github.io/toddler-games/privacy';
  static const _termsUrl = 'https://aboelnaga.github.io/toddler-games/terms';
  static const _supportEmail = 'support@example.com';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
          child: Text(l.settingsAbout,
              style: Theme.of(context).textTheme.titleLarge),
        ),
        const SizedBox(height: DesignTokens.space2),
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.data?.version ?? '—';
            return ListTile(title: Text(l.settingsVersion(version)));
          },
        ),
        ListTile(
          title: Text(l.settingsSupportEmail),
          trailing: const Icon(Icons.mail_outline),
          onTap: () =>
              launchUrl(Uri(scheme: 'mailto', path: _supportEmail)),
        ),
        ListTile(
          title: Text(l.settingsPrivacyPolicy),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => context.go('/parent-gate?dest=privacyPolicy'),
        ),
        ListTile(
          title: Text(l.settingsTerms),
          trailing: const Icon(Icons.open_in_new),
          onTap: () => context.go('/parent-gate?dest=terms'),
        ),
      ],
    );
  }

  static Future<void> openPrivacyPolicy() =>
      launchUrl(Uri.parse(_privacyUrl), mode: LaunchMode.externalApplication);
  static Future<void> openTerms() =>
      launchUrl(Uri.parse(_termsUrl), mode: LaunchMode.externalApplication);
}
```

(Privacy/Terms links go through the parent gate first; on success the router can launch the external URL — wire this in Step 7.)

- [ ] **Step 6: Write the settings screen test**

Create `test/features/settings/settings_screen_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';

Widget wrap(Widget child, {required ProviderContainer container}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: GoRouter(
        routes: [GoRoute(path: '/', builder: (_, __) => child)],
      ),
    ),
  );
}

void main() {
  late SharedPreferences prefs;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [
        settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
      ],
    );
    addTearDown(container.dispose);
  });

  group('SettingsScreen', () {
    testWidgets('shows the language segment with ar-EG selected initially',
        (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen(), container: container));
      await tester.pumpAndSettle();
      expect(find.text('Egyptian Arabic'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
    });

    testWidgets('toggling sound updates settings', (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen(), container: container));
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch).first;
      expect(tester.widget<Switch>(switchFinder).value, isTrue);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();

      expect(container.read(settingsProvider).soundEnabled, isFalse);
    });

    testWidgets('renders 5 per-game toggles', (tester) async {
      await tester.pumpWidget(wrap(const SettingsScreen(), container: container));
      await tester.pumpAndSettle();

      // Master sound + 5 game toggles = 6 switches.
      expect(find.byType(SwitchListTile), findsNWidgets(5));
    });
  });
}
```

- [ ] **Step 7: Run the test (should fail)**

```bash
flutter test test/features/settings/settings_screen_test.dart
```
Expected: FAIL.

- [ ] **Step 8: Implement SettingsScreen**

Replace `lib/features/settings/settings_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/settings/widgets/about_section.dart';
import 'package:toddler_games/features/settings/widgets/language_toggle.dart';
import 'package:toddler_games/features/settings/widgets/per_game_toggle_list.dart';
import 'package:toddler_games/features/settings/widgets/sound_toggle.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: DesignTokens.cream,
      appBar: AppBar(
        title: Text(l.settingsTitle),
        leading: IconButton(
          icon: const Icon(Icons.home_rounded),
          onPressed: () => context.go('/'),
          tooltip: 'Home',
        ),
        backgroundColor: DesignTokens.cream,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space4),
        children: const [
          LanguageToggle(),
          SizedBox(height: DesignTokens.space5),
          SoundToggle(),
          SizedBox(height: DesignTokens.space5),
          PerGameToggleList(),
          SizedBox(height: DesignTokens.space5),
          AboutSection(),
          SizedBox(height: DesignTokens.space7),
        ],
      ),
    );
  }
}
```

- [ ] **Step 9: Run the test**

```bash
flutter test test/features/settings/settings_screen_test.dart
flutter test --exclude-tags golden
```
Expected: green.

- [ ] **Step 10: Run the app — verify the full shell flow**

```bash
flutter run --flavor development --target lib/main_development.dart
```
Verify: home → gear → parent gate (math problem) → wrong answer regenerates → correct answer → settings → toggle language to English → labels switch → tap home arrow → back to home. Toggle sound off and back on. Toggle a game off → return home → tile is dimmed with lock icon.

- [ ] **Step 11: Commit**

```bash
git add pubspec.yaml pubspec.lock lib/features/settings/ \
  test/features/settings/settings_screen_test.dart
git commit -m "Add SettingsScreen with language/sound/games/about sections

- LanguageToggle: SegmentedButton ar-EG ↔ en, drives settingsProvider
- SoundToggle: master sound on/off Switch
- PerGameToggleList: 5 SwitchListTile rows, one per game; toggles
  settingsProvider.enabledGames
- AboutSection: version (via package_info_plus), support email
  (mailto:), privacy / terms links (routed through parent gate)
- Add url_launcher, package_info_plus deps

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 12: External Link Confirmation (Privacy / Terms)

The privacy and terms links should launch the system browser **only after** a fresh parent-gate confirmation. We routed clicks to `/parent-gate?dest=privacyPolicy|terms` in Task 11; now we make the router actually launch the URL on success.

**Files:**
- Modify: `lib/core/routing/router.dart` (handle privacyPolicy/terms destinations)

- [ ] **Step 1: Edit the router to launch URLs on those destinations**

In `lib/core/routing/router.dart`, edit the `onSuccess` callback in `_ParentGateRouteState`:

```dart
import 'package:toddler_games/features/settings/widgets/about_section.dart';
// (add this import at the top)
```

Replace `onSuccess` body:

```dart
onSuccess: () async {
  switch (widget.destination) {
    case GateDestination.settings:
      if (mounted) GoRouter.of(context).go('/settings');
    case GateDestination.privacyPolicy:
      await AboutSection.openPrivacyPolicy();
      if (mounted) GoRouter.of(context).go('/settings');
    case GateDestination.terms:
      await AboutSection.openTerms();
      if (mounted) GoRouter.of(context).go('/settings');
  }
},
```

- [ ] **Step 2: Manual verification (no automated test for external launch)**

`url_launcher` opens the system browser — not testable in unit tests without mocking. Manually:

```bash
flutter run --flavor development --target lib/main_development.dart
```

Steps: home → gear → solve → settings → tap "Privacy Policy" → parent gate → solve → system browser opens the URL → back to app → settings.

- [ ] **Step 3: Commit**

```bash
git add lib/core/routing/router.dart
git commit -m "Launch privacy/terms URLs after fresh parent-gate confirmation

GateDestination.privacyPolicy and .terms now invoke
AboutSection.openPrivacyPolicy/openTerms via url_launcher before
returning to settings. Ensures external links are gated even if the
user has just exited the gate.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 13: Golden Tests (Home + Parent Gate + Settings) in Both Locales

**Files:**
- Create: `test/goldens/home_screen_golden_test.dart`
- Create: `test/goldens/parent_gate_golden_test.dart`
- Create: `test/goldens/settings_screen_golden_test.dart`
- Create: `test/helpers/golden_helpers.dart` (shared setup)

Tagged `golden` so they run on macOS-only CI.

- [ ] **Step 1: Create the golden helpers**

Create `test/helpers/golden_helpers.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';
import 'package:toddler_games/core/theme/app_theme.dart';

Future<ProviderContainer> mockContainer() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(
    overrides: [
      settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
    ],
  );
}

Widget wrapForGolden(
  Widget child, {
  required ProviderContainer container,
  required Locale locale,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.light(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      home: child,
    ),
  );
}
```

- [ ] **Step 2: Write the home screen golden tests**

Create `test/goldens/home_screen_golden_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/home/home_screen.dart';
import '../helpers/golden_helpers.dart';

void main() {
  group('HomeScreen golden', () {
    testWidgets('renders correctly in English', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        const HomeScreen(),
        container: container,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('home_screen_en.png'),
      );
    });

    testWidgets('renders correctly in Egyptian Arabic (RTL)', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        const HomeScreen(),
        container: container,
        locale: const Locale('ar', 'EG'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(HomeScreen),
        matchesGoldenFile('home_screen_ar.png'),
      );
    });
  });
}
```

- [ ] **Step 3: Write the parent gate golden test**

Create `test/goldens/parent_gate_golden_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';
import '../helpers/golden_helpers.dart';

void main() {
  // Deterministic problem
  final problem = ParentGateProblem(a: 7, b: 3, choices: [8, 10, 12, 15]);

  group('ParentGateScreen golden', () {
    testWidgets('en', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        ParentGateScreen(
          problem: problem,
          localeId: 'en',
          onSuccess: () {},
        ),
        container: container,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ParentGateScreen),
        matchesGoldenFile('parent_gate_en.png'),
      );
    });

    testWidgets('ar-EG', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        ParentGateScreen(
          problem: problem,
          localeId: 'ar-EG',
          onSuccess: () {},
        ),
        container: container,
        locale: const Locale('ar', 'EG'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(ParentGateScreen),
        matchesGoldenFile('parent_gate_ar.png'),
      );
    });
  });
}
```

- [ ] **Step 4: Write the settings golden test**

Create `test/goldens/settings_screen_golden_test.dart`:

```dart
@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toddler_games/features/settings/settings_screen.dart';
import '../helpers/golden_helpers.dart';

void main() {
  group('SettingsScreen golden', () {
    testWidgets('en', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        const SettingsScreen(),
        container: container,
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('settings_screen_en.png'),
      );
    });

    testWidgets('ar-EG', (tester) async {
      final container = await mockContainer();
      addTearDown(container.dispose);
      await tester.pumpWidget(wrapForGolden(
        const SettingsScreen(),
        container: container,
        locale: const Locale('ar', 'EG'),
      ));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(SettingsScreen),
        matchesGoldenFile('settings_screen_ar.png'),
      );
    });
  });
}
```

- [ ] **Step 5: Generate the goldens (first run produces the reference images)**

```bash
flutter test --update-goldens --tags golden
```
Expected: golden PNGs generated under `test/goldens/`. **Inspect each one visually** — if any look wrong (truncated text, wrong language, RTL layout broken), fix the underlying screen before committing the golden as canonical.

- [ ] **Step 6: Re-run goldens without `--update-goldens` to confirm they match**

```bash
flutter test --tags golden
```
Expected: PASS.

- [ ] **Step 7: Commit**

```bash
git add test/
git commit -m "Add golden tests for home, parent gate, settings in en + ar-EG

- 6 golden images total (3 screens × 2 locales)
- Tagged 'golden' so they run on macOS-only CI
- Pinned via deterministic ParentGateProblem in gate tests
- Catches RTL regressions and theme/typography drift

Generated with: flutter test --update-goldens --tags golden

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 14: End-to-End Integration Test

**Files:**
- Create: `test/integration/shell_flow_test.dart`

A widget-level integration test that walks the full shell flow without launching a real device.

- [ ] **Step 1: Write the integration test**

Create `test/integration/shell_flow_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toddler_games/app/app.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/core/settings/settings_service.dart';

void main() {
  testWidgets('Full shell flow: home → gate → settings → toggle game → home',
      (tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsServiceProvider.overrideWithValue(SettingsService(prefs)),
        ],
        child: const App(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. We are on the home grid
    expect(find.byIcon(Icons.settings_rounded), findsOneWidget);

    // 2. Tap gear → parent gate appears
    await tester.tap(find.byIcon(Icons.settings_rounded));
    await tester.pumpAndSettle();
    expect(find.textContaining(' = '), findsOneWidget); // math problem

    // 3. There are 4 choice buttons. Tap them until we hit the right one.
    final buttons = find.byType(FilledButton);
    expect(buttons, findsNWidgets(4));

    // To find the correct answer deterministically, parse the problem from
    // the rendered text and compute it.
    final textWidgets = tester
        .widgetList<Text>(find.byType(Text))
        .toList();
    final probWidget = textWidgets.firstWhere(
      (t) => (t.data ?? '').contains(' = '),
    );
    final probText = probWidget.data!;
    final parts = probText.split(' + ');
    final aStr = parts.first.trim();
    final bAndTail = parts.last.split(' = ').first.trim();
    final a = _parseEitherNumeral(aStr);
    final b = _parseEitherNumeral(bAndTail);
    final correctAnswer = a + b;

    // Find the button labeled with correctAnswer
    final correctButton = find.byWidgetPredicate((w) {
      if (w is FilledButton) {
        final child = w.child;
        if (child is Text) {
          return _parseEitherNumeral(child.data ?? '') == correctAnswer;
        }
      }
      return false;
    });
    await tester.tap(correctButton);
    await tester.pumpAndSettle();

    // 4. We are now on settings
    expect(find.textContaining('Egyptian Arabic'), findsOneWidget);

    // 5. Toggle "Zoo" off (first SwitchListTile)
    final zooSwitch = find.byType(SwitchListTile).first;
    expect(tester.widget<SwitchListTile>(zooSwitch).value, isTrue);
    await tester.tap(zooSwitch);
    await tester.pumpAndSettle();

    // 6. Go home (home icon in app bar)
    await tester.tap(find.byIcon(Icons.home_rounded));
    await tester.pumpAndSettle();

    // 7. Zoo tile should be locked
    expect(find.byIcon(Icons.lock), findsOneWidget);
  });
}

int _parseEitherNumeral(String s) {
  final westernMatch = RegExp(r'\d+').stringMatch(s);
  if (westernMatch != null && westernMatch.isNotEmpty) {
    return int.parse(westernMatch);
  }
  // Arabic-Indic numerals
  const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var n = 0;
  var found = false;
  for (final ch in s.runes) {
    final idx = ar.indexOf(String.fromCharCode(ch));
    if (idx >= 0) {
      n = n * 10 + idx;
      found = true;
    } else if (found) {
      break;
    }
  }
  return n;
}
```

- [ ] **Step 2: Run the integration test**

```bash
flutter test test/integration/shell_flow_test.dart
```
Expected: PASS.

If it fails because the home arrow icon in the app bar uses a different IconData or the SwitchListTile structure differs, adjust selectors. The test verifies the user-visible flow, not exact widget tree.

- [ ] **Step 3: Commit**

```bash
git add test/integration/
git commit -m "Add end-to-end shell flow integration test

Walks: home → tap gear → solve parent gate → arrive at settings →
toggle Zoo off → return home → verify Zoo tile is locked.

Numeral parsing supports both Western and Arabic-Indic numerals to
keep the test locale-agnostic.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>"
```

---

## Task 15: Final Verification & Slice Tag

**Files:** none (verification only).

- [ ] **Step 1: Run the entire test suite + lint stack**

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --set-exit-if-changed .
flutter analyze --fatal-infos
dart run custom_lint
flutter test --exclude-tags golden
flutter test --tags golden
./scripts/check_forbidden_sdks.sh
./scripts/check_no_internet_permission.sh
```
Expected: every command exits 0.

- [ ] **Step 2: Manual smoke run on both platforms**

```bash
flutter run --flavor development --target lib/main_development.dart -d "iPhone 15"
# Walk the full flow: home → gear → math gate → settings → language toggle (verify Arabic strings flip in) → sound toggle → toggle a game → back to home → game is locked → tap any game tile → "coming soon" placeholder → home → done.

flutter run --flavor development --target lib/main_development.dart -d emulator-5554
# Same flow.
```
Expected: no crashes, no console errors.

- [ ] **Step 3: Tag the slice**

```bash
git tag -a slice-1-complete -m "Slice 1: app shell complete

Working app shell with:
- Theme + design tokens
- Riverpod settings + locale providers
- Persistent SharedPreferences-backed settings
- Home icon grid with 5 game tiles + lock state
- Parent gate with locale-aware math problem
- Settings screen: language, sound, per-game enable, About
- Privacy/Terms links behind a second parent-gate confirmation
- RTL support tested via goldens
- Full integration test of the home → gate → settings → home flow

No game logic yet — tiles route to a 'coming soon' placeholder.
Slice 2 (Zoo game) plugs into this shell."
```

- [ ] **Step 4: Inventory check**

```bash
git log --oneline | head -30
git tag --list
```

Expected: clean atomic commits, both `slice-0-complete` and `slice-1-complete` tags.

**Slice 1 is complete when:**
- ✅ App launches in dev flavor on iOS sim + Android emu
- ✅ Home grid shows 5 colored tiles + 1 reserved slot
- ✅ Gear icon → parent gate → wrong answer regenerates problem
- ✅ Correct answer → settings screen
- ✅ Language toggle switches the app to English instantly (and back)
- ✅ Sound toggle persists across restarts
- ✅ Per-game toggle dims a tile on the home grid with a lock icon
- ✅ Privacy / Terms links open the system browser after a fresh gate
- ✅ All tests pass (`flutter test`, golden tests on macOS)
- ✅ `slice-1-complete` git tag created

---

## Self-Review

Against the spec, this plan delivers:

- ✅ **Section 7.1 (Home screen)**: 2×3 grid with 5 tiles + 1 reserved slot (the GridView naturally leaves slot 6 empty). Gear icon bottom-right. ✓ — small note: the design spec also mentions a "fox icon bottom-left for home-return when inside a game" — implemented in PlaceholderGameScreen (Task 10).
- ✅ **Section 7.2 (Parent gate)**: math problem, 4 multiple choice, locale-aware numerals, wrong-answer regenerates a fresh problem. ✓
- ✅ **Section 7.3 (Settings)**: language toggle, sound master, per-game enable, About section with version + support email + privacy/terms links behind a second parent gate. ✓
- ✅ **Section 4 (Art direction → palette)**: implemented as DesignTokens. Touch target >= 60dp. ✓
- ✅ **Section 6 (Localization)**: ar (default) + en, runtime locale via provider, RTL via Flutter's built-in handling. Egyptian colloquial vocabulary in `app_ar.arb`. ✓
- ✅ **Section 8 (Compliance: no network)**: nothing in this slice adds a network call. url_launcher is a system-handoff (opens external browser); no app-controlled network traffic.
- ✅ **Section 9 (Architecture)**: pure Flutter, Riverpod 2, go_router, CustomPainter not yet needed (no painting in shell), shared_preferences persistence. ✓
- ✅ **Section 12 (Testing)**: unit tests for SettingsService, SettingsNotifier, locale provider, math generator; widget tests for parent gate, game tile, home, settings; goldens for home/gate/settings × en/ar; integration test for the flow. ✓
- ⚠ **Audio scope** (spec §5): No audio in Slice 1 — this is intentional. AudioService lands in Slice 2 with the first real game. The SettingsState already has `soundEnabled` ready to gate audio later.
- ⚠ **Asset bundle budget**: not exercised yet — no real assets bundled in this slice (only placeholder emoji). Real asset weight scrutiny starts in Slice 2.

**Placeholder scan:** searched for "TBD"/"TODO"/"implement later"/"appropriate"/"handle edge cases":
- One intentional `TODO(slice-7)` comment in `about_section.dart` for the real privacy URL / support email. Tagged with slice number, intentional.
- README "License TBD" carried over from Slice 0 — intentional.

**Type/name consistency:**
- `SettingsState` fields (`locale`, `soundEnabled`, `enabledGames`): used identically across SettingsService, SettingsNotifier, LanguageToggle, SoundToggle, PerGameToggleList, GameCatalog. ✓
- `settingsProvider` (not `settingsStateProvider` or `settingsNotifierProvider`): consistent across all consumers. ✓
- `localeProvider`: defined in `locale_notifier.dart`, consumed only in `app.dart`. ✓
- `GameCatalogEntry`: same field names across catalog definition and tile widget consumption. ✓
- Route paths: `/`, `/game/:id`, `/parent-gate?dest=...`, `/settings` — consistent across home, settings, gate navigation. ✓

**Scope:** focused — a single shippable shell. Single implementation plan. ✓

No issues found. Plan is ready for execution.

---

## Out of scope for this slice (covered in later slices)

- AudioService (`audioplayers` wrapper) — Slice 2
- Voice-over playback, animal sounds, sparkle SFX — Slice 2
- Any actual game logic — Slices 2–6
- Real launcher icon + splash with the fox mascot — pending Nano Banana generation (runs in parallel; non-blocking)
- Real privacy policy URL, support email, terms URL — Slice 7
- Asset weight budget tuning — Slice 6/7 once real assets land
- TestFlight upload, Play internal track, store metadata, age questionnaires — Slice 7

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-05-11-slice-1-app-shell.md`.

When ready to execute:

1. **Subagent-Driven (recommended)** — fresh subagent per task, review between tasks.
2. **Inline Execution** — tasks run in the same session with batch checkpoints.

Decision deferred until you start executing.
