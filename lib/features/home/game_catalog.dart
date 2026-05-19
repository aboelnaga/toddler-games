import 'package:flutter/material.dart';
import 'package:toddler_games/core/theme/design_tokens.dart';
import 'package:toddler_games/l10n/gen/app_localizations.dart';

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
  final String placeholderEmoji;
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
