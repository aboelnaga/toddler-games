import 'package:flutter/material.dart';

/// A single bubble in the Bubble Pop game.
///
/// Identity is [id]; equality and hashing are based on [id] alone so list
/// diffs (used by Flutter's key-aware reconciliation) stay cheap.
@immutable
class Bubble {
  const Bubble({
    required this.id,
    required this.position,
    required this.radius,
    required this.color,
    required this.velocityY,
  });

  final int id;
  final Offset position;
  final double radius;
  final Color color;
  final double velocityY;

  Bubble copyWith({Offset? position}) => Bubble(
    id: id,
    position: position ?? this.position,
    radius: radius,
    color: color,
    velocityY: velocityY,
  );

  @override
  bool operator ==(Object other) => other is Bubble && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
