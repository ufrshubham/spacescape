import 'dart:math';

import 'package:flame/collisions.dart';
// import 'package:flame/effects.dart';
import 'package:flame/experimental.dart';
import 'package:flame/particles.dart';
import 'package:flame/components.dart';
// import 'package:flame_noise/flame_noise.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/player_data.dart';
import '../models/spaceship_details.dart';

import 'game.dart';
import 'enemy.dart';
import 'bullet.dart';
import 'command.dart';
import 'audio_player_component.dart';

// This component class represents the player character in game.
class Player extends SpriteComponent
    with CollisionCallbacks, HasGameReference<SpacescapeGame>, KeyboardHandler {
  // Player joystick
  JoystickComponent joystick;

  // Player health.
  int _health = 100;
  int get health => _health;

  // Details of current spaceship.
  Spaceship _spaceship;

  // Type of current spaceship.
  SpaceshipType spaceshipType;

  // A reference to PlayerData so that
  // we can modify money.
  late PlayerData _playerData;
  int get score => _playerData.currentScore;

  // If true, player will shoot 3 bullets at a time.
  bool _shootMultipleBullets = false;

  // Controls for how long multi-bullet power up is active.
  late Timer _powerUpTimer;

  // Holds an object of Random class to generate random numbers.
  final _random = Random();

  // This method generates a random vector such that
  // its x component lies between [-100 to 100] and
  // y component lies between [200, 400]
  Vector2 getRandomVector() {
    return (Vector2.random(_random) - Vector2(0.5, -1)) * 200;
  }

  Player({
    required this.joystick,
    required this.spaceshipType,
    Sprite? sprite,
    Vector2? position,
    Vector2? size,
  })  : _spaceship = Spaceship.getSpaceshipByType(spaceshipType),
        super(sprite: sprite, position: position, size: size) {
    // Sets power up timer to 4 seconds. After 4 seconds,
    // multiple bullet will get deactivated.
    _powerUpTimer = Timer(4, onTick: () {
      _shootMultipleBullets = false;
    });
  }

  @override
  void onMount() {
    super.onMount();

    // Adding a circular hitbox with radius as 0.8 times
    // the smallest dimension of this components size.
    final shape = CircleHitbox.relative(
      0.8,
      parentSize: size,
      position: size / 2,
      anchor: Anchor.center,
    );
    add(shape);

    _playerData = Provider.of<PlayerData>(game.buildContext!, listen: false);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);

    // If other entity is an Enemy, reduce player's health by 10.
    if (other is Enemy) {
      // Make the camera shake, with custom intensity.
      // TODO: Investigate how camera shake should be implemented in new camera system.
      // game.primaryCamera.viewfinder.add(
      //   MoveByEffect(
      //     Vector2.all(10),
      //     PerlinNoiseEffectController(duration: 1),
      //   ),
      // );

      _health -= 10;
      if (_health <= 0) {
        _health = 0;
      }
    }
  }

  Vector2 keyboardDelta = Vector2.zero();
  static final _keysWatched = {
    LogicalKeyboardKey.keyW,
    LogicalKeyboardKey.keyA,
    LogicalKeyboardKey.keyS,
    LogicalKeyboardKey.keyD,
    LogicalKeyboardKey.space,
  };

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // Set this to zero first - if the user releases all keys pressed, then
    // the set will be empty and our vector non-zero.
    keyboardDelta.setZero();

    if (!_keysWatched.contains(event.logicalKey)) return true;

    if (event is RawKeyDownEvent &&
        !event.repeat &&
        event.logicalKey == LogicalKeyboardKey.space) {
      // pew pew!
      joystickAction();
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      keyboardDelta.y = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      keyboardDelta.x = -1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      keyboardDelta.y = 1;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      keyboardDelta.x = 1;
    }

    // Handled keyboard input
    return false;
  }

  // This method is called by game class for every frame.
  @override
  void update(double dt) {
    super.update(dt);

    _powerUpTimer.update(dt);

    // Increment the current position of player by (speed * delta time) along moveDirection.
    // Delta time is the time elapsed since last update. For devices with higher frame rates, delta time
    // will be smaller and for devices with lower frame rates, it will be larger. Multiplying speed with
    // delta time ensure that player speed remains same irrespective of the device FPS.
    if (!joystick.delta.isZero()) {
      position.add(joystick.relativeDelta * _spaceship.speed * dt);
    }

    if (!keyboardDelta.isZero()) {
      position.add(keyboardDelta * _spaceship.speed * dt);
    }

    // Clamp position of player such that the player sprite does not go outside the screen size.
    position.clamp(
      Vector2.zero() + size / 2,
      game.fixedResolution - size / 2,
    );

    // Adds thruster particles.
    final particleComponent = ParticleSystemComponent(
      particle: Particle.generate(
        count: 10,
        lifespan: 0.1,
        generator: (i) => AcceleratedParticle(
          acceleration: getRandomVector(),
          speed: getRandomVector(),
          position: (position.clone() + Vector2(0, size.y / 3)),
          child: CircleParticle(
            radius: 1,
            paint: Paint()..color = Colors.white,
          ),
        ),
      ),
    );

    game.world.add(particleComponent);
  }

  void joystickAction() {
    Bullet bullet = Bullet(
      sprite: game.spriteSheet.getSpriteById(28),
      size: Vector2(64, 64),
      position: position.clone(),
      level: _spaceship.level,
    );

    // Anchor it to center and add to game world.
    bullet.anchor = Anchor.center;
    game.world.add(bullet);

    // Ask audio player to play bullet fire effect.
    game.addCommand(Command<AudioPlayerComponent>(action: (audioPlayer) {
      audioPlayer.playSfx('laserSmall_001.ogg');
    }));

    // If multiple bullet is on, add two more
    // bullets rotated +-PI/6 radians to first bullet.
    if (_shootMultipleBullets) {
      for (int i = -1; i < 2; i += 2) {
        Bullet bullet = Bullet(
          sprite: game.spriteSheet.getSpriteById(28),
          size: Vector2(64, 64),
          position: position.clone(),
          level: _spaceship.level,
        );

        // Anchor it to center and add to game world.
        bullet.anchor = Anchor.center;
        bullet.direction.rotate(i * pi / 6);
        game.world.add(bullet);
      }
    }
  }

  // Adds given points to player score
  /// and also add it to [PlayerData.money].
  void addToScore(int points) {
    _playerData.currentScore += points;
    _playerData.money += points;

    // Saves player data to disk.
    _playerData.save();
  }

  // Increases health by give amount.
  void increaseHealthBy(int points) {
    _health += points;
    // Clamps health to 100.
    if (_health > 100) {
      _health = 100;
    }
  }

  // Resets player score, health and position. Should be called
  // while restarting and exiting the game.
  void reset() {
    _playerData.currentScore = 0;
    _health = 100;
    position = game.fixedResolution / 2;
  }

  // Changes the current spaceship type with given spaceship type.
  // This method also takes care of updating the internal spaceship details
  // as well as the spaceship sprite.
  void setSpaceshipType(SpaceshipType spaceshipType) {
    spaceshipType = spaceshipType;
    _spaceship = Spaceship.getSpaceshipByType(spaceshipType);
    sprite = game.spriteSheet.getSpriteById(_spaceship.spriteId);
  }

  // Allows player to first multiple bullets for 4 seconds when called.
  void shootMultipleBullets() {
    _shootMultipleBullets = true;
    _powerUpTimer.stop();
    _powerUpTimer.start();
  }
}
