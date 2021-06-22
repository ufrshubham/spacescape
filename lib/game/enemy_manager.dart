import 'dart:math';

import 'package:flame/sprite.dart';
import 'package:flame/components.dart';

import 'game.dart';
import 'enemy.dart';
import 'knows_game_size.dart';

// This component class takes care of spawning new enemy components
// randomly from top of the screen. It uses the HasGameRef mixin so that
// it can add child components.
class EnemyManager extends BaseComponent
    with KnowsGameSize, HasGameRef<SpacescapeGame> {
  // The timer which runs the enemy spawner code at regular interval of time.
  late Timer _timer;

  // Controls for how long EnemyManager should stop spawning new enemies.
  late Timer _freezeTimer;

  // A reference to spriteSheet contains enemy sprites.
  SpriteSheet spriteSheet;

  // Holds an object of Random class to generate random numbers.
  Random random = Random();

  EnemyManager({required this.spriteSheet}) : super() {
    // Sets the timer to call _spawnEnemy() after every 1 second, until timer is explicitly stops.
    _timer = Timer(1, callback: _spawnEnemy, repeat: true);

    // Sets freeze time to 2 seconds. After 2 seconds spawn timer will start again.
    _freezeTimer = Timer(2, callback: () {
      _timer.start();
    });
  }

  // Spawns a new enemy at random position at the top of the screen.
  void _spawnEnemy() {
    Vector2 initialSize = Vector2(64, 64);

    // random.nextDouble() generates a random number between 0 and 1.
    // Multiplying it by gameSize.x makes sure that the value remains between 0 and width of screen.
    Vector2 position = Vector2(random.nextDouble() * gameSize.x, 0);

    // Clamps the vector such that the enemy sprite remains within the screen.
    position.clamp(
      Vector2.zero() + initialSize / 2,
      gameSize - initialSize / 2,
    );

    Enemy enemy = Enemy(
      sprite: spriteSheet.getSpriteById(13),
      size: initialSize,
      position: position,
    );

    // Makes sure that the enemy sprite is centered.
    enemy.anchor = Anchor.center;

    // Add it to components list of game instance, instead of EnemyManager.
    // This ensures the collision detection working correctly.
    gameRef.add(enemy);
  }

  @override
  void onMount() {
    super.onMount();
    // Start the timer as soon as current enemy manager get prepared
    // and added to the game instance.
    _timer.start();
  }

  @override
  void onRemove() {
    super.onRemove();
    // Stop the timer if current enemy manager is getting removed from the
    // game instance.
    _timer.stop();
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update timers with delta time to make them tick.
    _timer.update(dt);
    _freezeTimer.update(dt);
  }

  // Stops and restarts the timer. Should be called
  // while restarting and exiting the game.
  void reset() {
    _timer.stop();
    _timer.start();
  }

  // Pauses spawn timer for 2 seconds when called.
  void freeze() {
    _timer.stop();
    _freezeTimer.stop();
    _freezeTimer.start();
  }
}
