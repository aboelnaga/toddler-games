import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/l10n/l10n.dart';

class PlaceholderGameScreen extends StatelessWidget {
  const PlaceholderGameScreen({required this.gameId, super.key});

  final String gameId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
