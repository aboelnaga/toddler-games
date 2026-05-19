import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/features/home/game_catalog.dart';
import 'package:toddler_games/l10n/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

/// Resolves the app version string. Overrideable in tests.
final versionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(settingsProvider);
    final versionAsync = ref.watch(versionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.settingsForGrownUps),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Close',
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView(
        children: [
          _SectionHeader(title: l.settingsLanguage),
          RadioGroup<String>(
            groupValue: settings.locale,
            onChanged: (v) {
              if (v != null) {
                unawaited(ref.read(settingsProvider.notifier).setLocale(v));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: Text(l.settingsLanguageArabic),
                  value: SupportedLocales.idFor(
                    SupportedLocales.arabicEgyptian,
                  ),
                ),
                RadioListTile<String>(
                  title: Text(l.settingsLanguageEnglish),
                  value: SupportedLocales.idFor(SupportedLocales.english),
                ),
              ],
            ),
          ),
          const Divider(),
          _SectionHeader(title: l.settingsSound),
          SwitchListTile(
            title: Text(
              settings.soundEnabled ? l.settingsSoundOn : l.settingsSoundOff,
            ),
            value: settings.soundEnabled,
            onChanged: (v) =>
                ref.read(settingsProvider.notifier).setSoundEnabled(enabled: v),
          ),
          const Divider(),
          _SectionHeader(title: l.settingsGames),
          for (final entry in GameCatalog.all)
            SwitchListTile(
              title: Text(entry.titleResolver(l)),
              value: settings.enabledGames.contains(entry.id),
              onChanged: (_) => ref
                  .read(settingsProvider.notifier)
                  .toggleGameEnabled(entry.id),
            ),
          const Divider(),
          _SectionHeader(title: l.settingsAbout),
          ListTile(
            title: Text(
              versionAsync.maybeWhen(
                data: l.settingsVersion,
                orElse: () => '',
              ),
            ),
          ),
          ListTile(
            title: Text(l.settingsPrivacyPolicy),
            trailing: const Icon(Icons.open_in_new),
            onTap: AboutSection.openPrivacyPolicy,
          ),
          ListTile(
            title: Text(l.settingsTerms),
            trailing: const Icon(Icons.open_in_new),
            onTap: AboutSection.openTerms,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

/// External link helpers for parent-facing legal pages.
/// Wired into the parent-gate flow in Task 12.
abstract final class AboutSection {
  static const _privacyPolicyUrl =
      'https://aboalnga1.github.io/toddler-games/privacy';
  static const _termsUrl = 'https://aboalnga1.github.io/toddler-games/terms';

  static Future<void> openPrivacyPolicy() =>
      launchUrl(Uri.parse(_privacyPolicyUrl));

  static Future<void> openTerms() => launchUrl(Uri.parse(_termsUrl));
}
