import 'dart:math';

import 'package:flame/components.dart';
import 'package:spacescape/game/knows_game_size.dart';

// This class represent an enemy component.
class Enemy extends SpriteComponent with KnowsGameSize {
  // The speed of this enemy.
  double _speed = 250;

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    // Rotates the enemy component by 180 degrees. This is needed because
    // all the sprites initially face the same direct, but we want enemies to be
    // moving in opposite direction.
    angle = pi;
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the position of this enemy using its speed and delta time.
    this.position += Vector2(0, 1) * _speed * dt;

    // If the enemy leaves the screen, destroy it.
    if (this.position.y > this.gameSize.y) {
      remove();
    }
  }
}
