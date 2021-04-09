import 'package:flame/components.dart';

// This component represent a bullet in game world.
class Bullet extends SpriteComponent {
  // Speed of the bullet.
  double _speed = 450;

  Bullet({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size);

  @override
  void update(double dt) {
    super.update(dt);

    // Moves the bullet to a new position with _speed.
    this.position += Vector2(0, -1) * this._speed * dt;

    // If bullet crosses the upper boundary of screen
    // mark it to be removed it from the game world.
    if (this.position.y < 0) {
      remove();
    }
  }
}
