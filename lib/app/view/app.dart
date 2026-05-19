import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toddler_games/core/locale/locale_notifier.dart';
import 'package:toddler_games/core/routing/router.dart';
import 'package:toddler_games/core/theme/app_theme.dart';
import 'package:toddler_games/l10n/l10n.dart';

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
