import 'package:flutter/material.dart';

// Locales the app ships in v1.
// Default locale is Egyptian Arabic. English is the toggleable secondary.
// MSA is reserved for v2; do not add it here without a spec memo.
abstract final class SupportedLocales {
  static const Locale arabicEgyptian = Locale('ar', 'EG');
  static const Locale english = Locale('en');

  static const Locale defaultLocale = arabicEgyptian;

  static const List<Locale> all = <Locale>[arabicEgyptian, english];

  /// Stable string id stored in settings (`SettingsState.locale`).
  static String idFor(Locale locale) {
    if (locale.countryCode != null && locale.countryCode!.isNotEmpty) {
      return '${locale.languageCode}-${locale.countryCode}';
    }
    return locale.languageCode;
  }

  /// Reverse of [idFor]. Returns [defaultLocale] if the id is unknown.
  static Locale fromId(String id) {
    for (final l in all) {
      if (idFor(l) == id) return l;
    }
    return defaultLocale;
  }

  /// Whether the given locale should render RTL.
  static bool isRtl(Locale locale) => locale.languageCode == 'ar';
}
