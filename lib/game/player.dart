import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

import '../models/spaceship_details.dart';

import 'command.dart';
import 'knows_game_size.dart';
import 'bullet.dart';
import 'enemy.dart';
import 'game.dart';

// This component class represents the player character in game.
class Player extends SpriteComponent
    with
        KnowsGameSize,
        Hitbox,
        Collidable,
        JoystickListener,
        HasGameRef<SpacescapeGame> {
  // Controls in which direction player should move. Magnitude of this vector does not matter.
  // It is just used for getting a direction.
  Vector2 _moveDirection = Vector2.zero();

  // Player score.
  int _score = 0;
  int get score => _score;

  // Player health.
  int _health = 100;
  int get health => _health;

  // Details of current spaceship.
  Spaceship _spaceship;

  // Type of current spaceship.
  SpaceshipType spaceshipType;

  Random _random = Random();

  // This method generates a random vector such that
  // its x component lies between [-100 to 100] and
  // y component lies between [200, 400]
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Player({
    required this.spaceshipType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  })  : this._spaceship = Spaceship.getSpaceshipByType(spaceshipType),
        super(sprite: sprite, position: position, size: size);

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.8 times
    // the smallest dimension of this components size.
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    // If other entity is an Enemy, reduce player's health by 10.
    if (other is Enemy) {
      // Make the camera shake.
      gameRef.camera.shake();

      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  // This method is called by game class for every frame.
  @override
  void update(double dt) {
    super.update(dt);

    // Increment the current position of player by (speed * delta time) along moveDirection.
    // Delta time is the time elapsed since last update. For devices with higher frame rates, delta time
    // will be smaller and for devices with lower frame rates, it will be larger. Multiplying speed with
    // delta time ensure that player speed remains same irrespective of the device FPS.
    this.position += _moveDirection.normalized() * _spaceship.speed * dt;

    // Clamp position of player such that the player sprite does not go outside the screen size.
    this.position.clamp(
          Vector2.zero() + this.size / 2,
          gameSize - this.size / 2,
        );

    // Adds thruster particles.
    final particleComponent = ParticleComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector().toOffset(),
          speed: getRandomVector().toOffset(),
          position:
              (this.position.clone() + Vector2(0, this.size.y / 3)).toOffset(),
          child: CircleParticle(
            radius: 1,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );

    gameRef.add(particleComponent);
  }

  // Changes the current move direction with given new move direction.
  void setMoveDirection(Vector2 newMoveDirection) {
    _moveDirection = newMoveDirection;
  }

  @override
  void joystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.down) {
      Bullet bullet = Bullet(
        sprite: gameRef.spriteSheet.getSpriteById(28),
        size: Vector2(64, 64),
        position: this.position.clone(),
      );

      // Anchor it to center and add to game world.
      bullet.anchor = Anchor.center;
      gameRef.add(bullet);
    }

    // Temporary code to test Command system.
    if (event.id == 1 && event.event == ActionEvent.down) {
      final command = Command<Enemy>(action: (enemy) {
        enemy.destroy();
      });

      gameRef.addCommand(command);
    }
  }

  @override
  void joystickChangeDirectional(JoystickDirectionalEvent event) {
    switch (event.directional) {
      case JoystickMoveDirectional.moveUp:
        this.setMoveDirection(Vector2(0, -1));
        break;
      case JoystickMoveDirectional.moveUpLeft:
        this.setMoveDirection(Vector2(-1, -1));
        break;
      case JoystickMoveDirectional.moveUpRight:
        this.setMoveDirection(Vector2(1, -1));
        break;
      case JoystickMoveDirectional.moveRight:
        this.setMoveDirection(Vector2(1, 0));
        break;
      case JoystickMoveDirectional.moveDown:
        this.setMoveDirection(Vector2(0, 1));
        break;
      case JoystickMoveDirectional.moveDownRight:
        this.setMoveDirection(Vector2(1, 1));
        break;
      case JoystickMoveDirectional.moveDownLeft:
        this.setMoveDirection(Vector2(-1, 1));
        break;
      case JoystickMoveDirectional.moveLeft:
        this.setMoveDirection(Vector2(-1, 0));
        break;
      case JoystickMoveDirectional.idle:
        this.setMoveDirection(Vector2.zero());
        break;
    }
  }

  // Adds given points to player score.
  void addToScore(int points) {
    _score += points;
  }

  // Resets player score, health and position. Should be called
  // while restarting and exiting the game.
  void reset() {
    this._score = 0;
    this._health = 100;
    this.position = gameRef.viewport.canvasSize / 2;
  }

  // Changes the current spaceship type with given spaceship type.
  // This method also takes care of updating the internal spaceship details
  // as well as the spaceship sprite.
  void setSpaceshipType(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    this._spaceship = Spaceship.getSpaceshipByType(spaceshipType);
    sprite = gameRef.spriteSheet.getSpriteById(_spaceship.spriteId);
  }
}
