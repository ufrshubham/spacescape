import 'package:flame/components.dart';
import 'package:flame/geometry.dart';

import 'enemy.dart';

// This component represent a bullet in game world.
class Bullet extends SpriteComponent with Hitbox, Collidable {
  // Speed of the bullet.
  double _speed = 450;

  // Controls the direction in which bullet travels.
  Vector2 direction = Vector2(0, -1);

  // Level of this bullet. Essentially represents the
  // level of spaceship that fired this bullet.
  final int level;

  Bullet({
    required Sprite? sprite,
    required Vector2? position,
    required Vector2? size,
    required this.level,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.4 times
    //  the smallest dimension of this components size.
    final shape = HitboxCircle(definition: 0.4);
    addShape(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    // If the other Collidable is Enemy, remove this bullet.
    if (other is Enemy) {
      this.remove();
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Moves the bullet to a new position with _speed and direction.
    this.position += direction * this._speed * dt;

    // If bullet crosses the upper boundary of screen
    // mark it to be removed it from the game world.
    if (this.position.y < 0) {
      remove();
    }
  }
}
