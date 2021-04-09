import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spacescape/game/bullet.dart';
import 'package:spacescape/game/enemy.dart';
import 'package:spacescape/game/enemy_manager.dart';
import 'package:spacescape/game/knows_game_size.dart';
import 'package:spacescape/game/player.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends BaseGame with PanDetector, TapDetector {
  // Stores a reference to player component.
  late Player player;

  // Stores a reference to the main spritesheet.
  late SpriteSheet _spriteSheet;

  // Stores a reference to an enemy manager component.
  late EnemyManager _enemyManager;

  // These represent the start and updated pointer position.
  // Null values represent that user is not touching the screen at the moment.
  Offset? _pointerStartPosition;
  Offset? _pointerCurrentPosition;

  // Controls how big the joystick zone is.
  final double _joystickRadius = 60;

  // Controls how big the joystick head is.
  final double _joystickThumbRadius = 20;

  // Controls how big the deadzone is.
  final double _deadZoneRadius = 10;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    // Loads and caches the image for later use.
    await images.load('simpleSpace_tilesheet@2.png');

    _spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet@2.png'),
      columns: 8,
      rows: 6,
    );

    player = Player(
      sprite: _spriteSheet.getSpriteById(6),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );

    // Makes sure that the sprite is centered.
    player.anchor = Anchor.center;
    add(player);

    _enemyManager = EnemyManager(spriteSheet: _spriteSheet);
    add(_enemyManager);
  }

  // Render method comes from Flame's Game class and gets called for every iteration of game loop.
  // It exposes the underlying Canvas on which components are being drawn.
  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // If user is touching the screen, draw a translucent circle at _pointerStartPosition with radius as _joystickRadius.
    if (_pointerStartPosition != null) {
      canvas.drawCircle(
        _pointerStartPosition!,
        _joystickRadius,
        Paint()..color = Colors.grey.withAlpha(100),
      );
    }

    // If user is touching the screen, draw a translucent circle at delta with radius as _joystickThumbRadius.
    if (_pointerCurrentPosition != null) {
      var delta = _pointerCurrentPosition! - _pointerStartPosition!;

      // If delta.distance is more that _joystickRadius, it means current position of pointer is outside the circle.
      if (delta.distance > _joystickRadius) {
        // In this case we will clamp the delta to stay within the big circle.
        delta = _pointerStartPosition! +
            (Vector2(delta.dx, delta.dy).normalized() * _joystickRadius)
                .toOffset();
      } else {
        // If current position of pointer in within big circle, use the current position as center of small circle.
        delta = _pointerCurrentPosition!;
      }

      canvas.drawCircle(
        delta,
        _joystickThumbRadius,
        Paint()..color = Colors.white.withAlpha(100),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Get a list of all the bullets in game world.
    final bullets = this.components.whereType<Bullet>();

    // Loop over all the enemies added under _enemyManager.
    for (final enemy in _enemyManager.children.whereType<Enemy>()) {
      // If current enemy is already marked to be removed, skip it.
      if (enemy.shouldRemove) {
        continue;
      }

      // Loop over all the bullets.
      for (final bullet in bullets) {
        // If current bullet is already marked to be removed, skip it.
        if (bullet.shouldRemove) {
          continue;
        }

        // If center of current bullet is completely inside
        // sprite rectangle of current enemy, it means they have collided.
        // In such case, mark both of them to be removed.
        if (enemy.containsPoint(bullet.absoluteCenter)) {
          enemy.remove();
          bullet.remove();
          break;
        }
      }

      // Player-enemy collision.
      if (player.containsPoint(enemy.absoluteCenter)) {
        print("Enemy hit player!!!");
      }
    }
  }

  @override
  void onPanStart(DragStartDetails details) {
    // Initially, both small and big circles will be placed at the same location.
    _pointerStartPosition = details.globalPosition;
    _pointerCurrentPosition = details.globalPosition;
  }

  @override
  void onPanUpdate(DragUpdateDetails details) {
    _pointerCurrentPosition = details.globalPosition;
    var delta = _pointerCurrentPosition! - _pointerStartPosition!;

    // Move player only if joystick is moved beyond the deadzone.
    if (delta.distance > _deadZoneRadius) {
      player.setMoveDirection(Vector2(delta.dx, delta.dy));
    } else {
      player.setMoveDirection(Vector2.zero());
    }
  }

  @override
  void onPanEnd(DragEndDetails details) {
    // Reset start and current position to null and stop player movement.
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
  }

  @override
  void onPanCancel() {
    // Reset start and current position to null and stop player movement.
    _pointerStartPosition = null;
    _pointerCurrentPosition = null;
    player.setMoveDirection(Vector2.zero());
  }

  @override
  void onTapDown(TapDownDetails details) {
    super.onTapDown(details);

    // When players tap the screen, spawn a new bullet
    // at player's spaceship's current position.
    Bullet bullet = Bullet(
      sprite: _spriteSheet.getSpriteById(28),
      size: Vector2(64, 64),
      position: this.player.position,
    );

    // Anchor it to center and add to game world.
    bullet.anchor = Anchor.center;
    add(bullet);
  }

  @override
  void prepare(Component c) {
    super.prepare(c);

    // If the component being prepared is of type KnowsGameSize,
    // call onResize() on it so that it stores the current game screen size.
    if (c is KnowsGameSize) {
      c.onResize(this.size);
    }
  }

  @override
  void onResize(Vector2 canvasSize) {
    super.onResize(canvasSize);

    // Loop over all the components of type KnowsGameSize and resize then as well.
    this.components.whereType<KnowsGameSize>().forEach((component) {
      component.onResize(this.size);
    });
  }
}
