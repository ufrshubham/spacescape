import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'command.dart';
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

  // Displays player score on top left.
  late TextComponent _playerScore;

  // Displays player helth on top right.
  late TextComponent _playerHealth;

  // List of commands to be processed in current update.
  final _commandList = List<Command>.empty(growable: true);

  // List of commands to be processed in next update.
  final _addLaterCommandList = List<Command>.empty(growable: true);

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
        JoystickAction(
          actionId: 1,
          size: 60,
          color: Colors.red,
          margin: const EdgeInsets.all(
            100,
          ),
        ),
      ],
    );

    // Make sure to add player as an observer of this joystick.
    joystick.addObserver(_player);
    add(joystick);

    // Create text component for player score.
    _playerScore = TextComponent(
      'Score: 0',
      position: Vector2(10, 10),
      config: TextConfig(
        color: Colors.white,
        fontSize: 16,
      ),
    );

    // Setting isHud to true makes sure that this component
    // does not get affected by camera's transformations.
    _playerScore.isHud = true;

    add(_playerScore);

    // Create text component for player health.
    _playerHealth = TextComponent(
      'Health: 100%',
      position: Vector2(size.x - 10, 10),
      config: TextConfig(
        color: Colors.white,
        fontSize: 16,
      ),
    );

    // Anchor to top right as we want the top right
    // corner of this component to be at a specific position.
    _playerHealth.anchor = Anchor.topRight;

    // Setting isHud to true makes sure that this component
    // does not get affected by camera's transformations.
    _playerHealth.isHud = true;

    add(_playerHealth);

    this.camera.shakeIntensity = 20;
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

  @override
  void update(double dt) {
    super.update(dt);

    // Run each command from _commandList on each
    // component from components list. The run()
    // method of Command is no-op if the command is
    // not valid for given component.
    _commandList.forEach((command) {
      components.forEach((component) {
        command.run(component);
      });
    });

    // Remove all the commands that are processed and
    // add all new commands to be processed in next update.
    _commandList.clear();
    _commandList.addAll(_addLaterCommandList);
    _addLaterCommandList.clear();

    // Update score and health components with latest values.
    _playerScore.text = 'Score: ${_player.score}';
    _playerHealth.text = 'Health: ${_player.health}%';
  }

  @override
  void render(Canvas canvas) {
    // Draws a rectangular health bar at top right corner.
    canvas.drawRect(
      Rect.fromLTWH(size.x - 110, 10, _player.health.toDouble(), 20),
      Paint()..color = Colors.blue,
    );

    super.render(canvas);
  }

  // Adds given command to command list.
  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }
}
