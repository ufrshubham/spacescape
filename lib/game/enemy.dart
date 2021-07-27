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
import 'audio_player_component.dart';

import '../models/enemy_data.dart';

// This class represent an enemy component.
class Enemy extends SpriteComponent
    with KnowsGameSize, Hitbox, Collidable, HasGameRef<SpacescapeGame> {
  // The speed of this enemy.
  double _speed = 250;

  // This direction in which this Enemy will move.
  // Defaults to vertically downwards.
  Vector2 moveDirection = Vector2(0, 1);

  // Controls for how long enemy should be freezed.
  late Timer _freezeTimer;

  // Holds an object of Random class to generate random numbers.
  Random _random = Random();

  // The data required to create this enemy.
  final EnemyData enemyData;

  // Represents health of this enemy.
  int _hitPoints = 10;

  // To display health in game world.
  TextComponent _hpText = TextComponent(
    '10 HP',
    textRenderer: TextPaint(
      config: TextPaintConfig(
        color: Colors.white,
        fontSize: 12,
        fontFamily: 'BungeeInline',
      ),
    ),
  );

  // This method generates a random vector with its angle
  // between from 0 and 360 degrees.
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2.random(_random)) * 500;
  }

  // Returns a random direction vector with slight angle to +ve y axis.
  Vector2 getRandomDirection() {
    return (Vector2.random(_random) - Vector2(0.5, -1)).normalized();
  }

  Enemy({
    required Sprite? sprite,
    required this.enemyData,
    required Vector2? position,
    required Vector2? size,
  }) : super(sprite: sprite, position: position, size: size) {
    // Rotates the enemy component by 180 degrees. This is needed because
    // all the sprites initially face the same direct, but we want enemies to be
    // moving in opposite direction.
    angle = pi;

    // Set the current speed from enemyData.
    _speed = enemyData.speed;

    // Set hitpoint to correct value from enemyData.
    _hitPoints = enemyData.level * 10;
    _hpText.text = '$_hitPoints HP';

    // Sets freeze time to 2 seconds. After 2 seconds speed will be reset.
    _freezeTimer = Timer(2, callback: () {
      _speed = enemyData.speed;
    });

    // If this enemy can move horizontally, randomize the move direction.
    if (enemyData.hMove) {
      moveDirection = getRandomDirection();
    }
  }

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.8 times
    // the smallest dimension of this components size.
    final shape = HitboxCircle(definition: 0.8);
    addShape(shape);

    // As current component is already rotated by pi radians,
    // the text component needs to be again rotated by pi radians
    // so that it is displayed correctly.
    _hpText.angle = pi;

    // To place the text just behind the enemy.
    _hpText.position = Vector2(50, 80);

    // Add as child of current component.
    addChild(_hpText);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, Collidable other) {
    super.onCollision(intersectionPoints, other);

    if (other is Bullet) {
      // If the other Collidable is a Bullet,
      // reduce health by level of bullet times 10.
      _hitPoints -= other.level * 10;
    } else if (other is Player) {
      // If the other Collidable is Player,
      // reduce health to zero at once.
      _hitPoints = 0;
    }
  }

  // This method will destory this enemy.
  void destroy() {
    // Ask audio player to play enemy destroy effect.
    gameRef.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laser1.ogg');
    }));

    this.remove();

    // Before dying, register a command to increase
    // player's score by 1.
    final command = Command<Player>(action: (player) {
      // Use the correct killPoint to increase player's score.
      player.addToScore(enemyData.killPoint);
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

    // Sync-up text component and value of hitPoints.
    _hpText.text = '$_hitPoints HP';

    // If hitPoints have reduced to zero,
    // destroy this enemy.
    if (_hitPoints <= 0) {
      destroy();
    }

    _freezeTimer.update(dt);

    // Update the position of this enemy using its speed and delta time.
    this.position += moveDirection * _speed * dt;

    // If the enemy leaves the screen, destroy it.
    if (this.position.y > this.gameSize.y) {
      remove();
    } else if ((this.position.x < this.size.x / 2) ||
        (this.position.x > (this.gameSize.x - size.x / 2))) {
      // Enemy is going outside vertical screen bounds, flip its x direction.
      moveDirection.x *= -1;
    }
  }

  // Pauses enemy for 2 seconds when called.
  void freeze() {
    _speed = 0;
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
