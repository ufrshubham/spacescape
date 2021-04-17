import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'enemy_manager.dart';
import 'knows_game_size.dart';
import 'player.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends BaseGame
    with HasCollidables, HasDraggableComponents {
  // Stores a reference to player component.
  late Player _player;

  // Stores a reference to the main spritesheet.
  late SpriteSheet spriteSheet;

  // Stores a reference to an enemy manager component.
  late EnemyManager _enemyManager;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    // Loads and caches the image for later use.
    await images.load('simpleSpace_tilesheet@2.png');

    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: images.fromCache('simpleSpace_tilesheet@2.png'),
      columns: 8,
      rows: 6,
    );

    _player = Player(
      sprite: spriteSheet.getSpriteById(6),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );

    // Makes sure that the sprite is centered.
    _player.anchor = Anchor.center;
    add(_player);

    _enemyManager = EnemyManager(spriteSheet: spriteSheet);
    add(_enemyManager);

    // Create a basic joystick component with a joystick on left
    // and a fire button on right.
    final joystick = JoystickComponent(
      gameRef: this,
      directional: JoystickDirectional(
        size: 100,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          size: 60,
          margin: const EdgeInsets.all(
            30,
          ),
        ),
      ],
    );

    // Make sure to add player as an observer of this joystick.
    joystick.addObserver(_player);
    add(joystick);
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
