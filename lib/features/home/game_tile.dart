import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/features/home/game_catalog.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

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
    final l = AppLocalizations.of(context);
    final dim = !enabled;
    return Semantics(
      label: entry.titleResolver(l),
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dim ? 0.35 : 1,
          child: Container(
            decoration: BoxDecoration(
              color: entry.tileColor,
              borderRadius: BorderRadius.circular(DesignTokens.radiusL),
              boxShadow: dim
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
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
                    style: const TextStyle(
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
