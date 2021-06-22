import 'dart:math';

import 'package:flame/geometry.dart';
import 'package:flame/particles.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'game.dart';
import 'bullet.dart';
import 'player.dart';
import 'command.dart';
import 'knows_game_size.dart';

// This class represent an enemy component.
class Enemy extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, HasGameRef<SpacescapeGame> {
  // The speed of this enemy.
  double _speed = 250;

  // Controls for how long enemy should be freezed.
  late Timer _freezeTimer;

  // Holds an object of Random class to generate random numbers.
  Random _random = Random();

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  Enemy({
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    // Rotates the enemy component by 180 degrees. This is needed because
    // all the sprites initially face the same direct, but we want enemies to be
    // moving in opposite direction.
    angle = pi;

    // Sets freeze time to 2 seconds. After 2 seconds speed will be reset.
    _freezeTimer = Timer(2, callback: () {
      _speed = 250;
    });
  }

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

    // If the other Collidable is a Bullet, remove this Enemy.
    if (other is Bullet || other is Player) {
      destroy();
    }
  }

  // This method will destory this enemy.
  void destroy() {
    this.remove();

    // Before dying, register a command to increase
    // player's score by 1.
    final command = Command<Player>(action: (player) {
      player.addToScore(1);
    });
    gameRef.addCommand(command);

    // Generate 20 white circle particles with random speed and acceleration,
    // at current position of this enemy. Each particles lives for exactly
    // 0.1 seconds and will get removed from the game world after that.
    final particleComponent = ParticleComponent(
      particle: Particle.generate(
        count: 20,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: this.position.clone(),
          child: CircleParticle(
            radius: 2,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );

    gameRef.add(particleComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _freezeTimer.update(dt);

    // Update the position of this enemy using its speed and delta time.
    this.position += Vector2(0, 1) * _speed * dt;

    // If the enemy leaves the screen, destroy it.
    if (this.position.y > this.gameSize.y) {
      remove();
    }
  }

  // Pauses enemy for 2 seconds when called.
  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
