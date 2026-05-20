import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/gate/gate_arguments.dart';
import 'package:toddler_games/core/gate/parent_gate_problem.dart';
import 'package:toddler_games/core/gate/parent_gate_screen.dart';
import 'package:toddler_games/core/settings/settings_notifier.dart';
import 'package:toddler_games/features/games/_placeholder/placeholder_game_screen.dart';
import 'package:toddler_games/features/games/bubble_pop/bubble_pop_screen.dart';
import 'package:toddler_games/features/games/finger_paint/finger_paint_screen.dart';
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
          if (id == 'finger_paint') return const FingerPaintScreen();
          if (id == 'bubble_pop') return const BubblePopScreen();
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
            unawaited(AboutSection.openPrivacyPolicy());
            GoRouter.of(context).go('/');
          case GateDestination.terms:
            unawaited(AboutSection.openTerms());
            GoRouter.of(context).go('/');
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
