import 'package:flame/components.dart';

// This component class represents the player character in game.
class Player extends SpriteComponent {
  // Controls in which direction player should move. Magnitude of this vector does not matter.
  // It is just used for getting a direction.
  Vector2 _moveDirection = Vector2.zero();

  // Move speed of this player.
  double _speed = 300;

  Player({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size);

  // This method is called by game class for every frame.
  @override
  void update(double dt) {
    super.update(dt);

    // Increment the current position of player by speed * delta time along moveDirection.
    // Delta time is the time elapsed since last update. For devices with higher frame rates, delta time
    // will be smaller and for devices with lower frame rates, it will be larger. Multiplying speed with
    // delta time ensure that player speed remains same irrespective of the device FPS.
    this.position += _moveDirection.normalized() * _speed * dt;
  }

  // Changes the current move direction with given new move direction.
  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }
}
