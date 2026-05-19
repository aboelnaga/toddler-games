import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/locale/supported_locales.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';

/// Derived locale, computed from the current settings state.
///
/// Widgets that need to react to locale changes watch this provider.
/// `MaterialApp.router(locale: ref.watch(localeProvider))` drives runtime
/// locale switching and RTL via Flutter's built-in Directionality.
final localeProvider = Provider<Locale>((ref) {
  final id = ref.watch(settingsProvider.select((s) => s.locale));
  return SupportedLocales.fromId(id);
});
