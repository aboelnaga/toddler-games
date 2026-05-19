import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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
