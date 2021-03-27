import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:spacescape/game/player.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends BaseGame with PanDetector {
  // Stores a reference to player component.
  late Player player;

  // These represent the start and updated pointer position.
  // Null values represent that user is not touching the screen at the moment.
  Offset? _pointerStartPosition;
  Offset? _pointerCurrentPosition;

  // Controls how big the joystick zone is.
  final double _joystickRadius = 60;

  final double _joystickThumbRadius = 20;

  // Controls how big the deadzone is.
  final double _deadZoneRadius = 10;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    await images.load('simpleSpace_tilesheet@2.png');

    final spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet@2.png'),
      columns: 8,
      rows: 6,
    );

    player = Player(
      sprite: spriteSheet.getSpriteById(6),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );

    // Makes sure that the sprite is centered.
    player.anchor = Anchor.center;

    add(player);
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
}
