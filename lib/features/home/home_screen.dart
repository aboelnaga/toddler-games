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
                    onPressed: () => context.go('/parent-gate?dest=settings'),
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
