import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/overlays/pause_menu.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/game_over_menu.dart';

import '../models/player_data.dart';
import '../models/spaceship_details.dart';

import 'enemy.dart';
import 'player.dart';
import 'bullet.dart';
import 'command.dart';
import 'power_ups.dart';
import 'enemy_manager.dart';
import 'knows_game_size.dart';
import 'power_up_manager.dart';
import 'audio_player_component.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends BaseGame
    with HasCollidables, HasDraggableComponents {
  // Stores a reference to player component.
  late Player _player;

  // Stores a reference to the main spritesheet.
  late SpriteSheet spriteSheet;

  // Stores a reference to an enemy manager component.
  late EnemyManager _enemyManager;

  // Stores a reference to an power-up manager component.
  late PowerUpManager _powerUpManager;

  // Displays player score on top left.
  late TextComponent _playerScore;

  // Displays player helth on top right.
  late TextComponent _playerHealth;

  late AudioPlayerComponent _audioPlayerComponent;

  // List of commands to be processed in current update.
  final _commandList = List<Command>.empty(growable: true);

  // List of commands to be processed in next update.
  final _addLaterCommandList = List<Command>.empty(growable: true);

  // Indicates wheater the game world has been already initilized.
  bool _isAlreadyLoaded = false;

  // This method gets called by Flame before the game-loop begins.
  // Assets loading and adding component should be done here.
  @override
  Future<void> onLoad() async {
    // Initilize the game world only one time.
    if (!_isAlreadyLoaded) {
      // Loads and caches all the images for later use.
      await images.loadAll([
        'simpleSpace_tilesheet@2.png',
        'freeze.png',
        'icon_plusSmall.png',
        'multi_fire.png',
        'nuke.png',
      ]);

      _audioPlayerComponent = AudioPlayerComponent();
      add(_audioPlayerComponent);

      ParallaxComponent _stars = await ParallaxComponent.load(
        [
          ParallaxImageData('stars1.png'),
          ParallaxImageData('stars2.png'),
        ],
        repeat: ImageRepeat.repeat,
        baseVelocity: Vector2(0, -50),
        velocityMultiplierDelta: Vector2(0, 1.5),
      );
      add(_stars);

      spriteSheet = SpriteSheet.fromColumnsAndRows(
        image: images.fromCache('simpleSpace_tilesheet@2.png'),
        columns: 8,
        rows: 6,
      );

      /// As build context is not valid in onLoad() method, we
      /// cannot get current [PlayerData] here. So initilize player
      /// with the default SpaceshipType.Canary.
      final spaceshipType = SpaceshipType.Canary;
      final spaceship = Spaceship.getSpaceshipByType(spaceshipType);

      _player = Player(
        spaceshipType: spaceshipType,
        sprite: spriteSheet.getSpriteById(spaceship.spriteId),
        size: Vector2(64, 64),
        position: viewport.canvasSize / 2,
      );

      // Makes sure that the sprite is centered.
      _player.anchor = Anchor.center;
      add(_player);

      _enemyManager = EnemyManager(spriteSheet: spriteSheet);
      add(_enemyManager);

      _powerUpManager = PowerUpManager();
      add(_powerUpManager);

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

      // Create text component for player score.
      _playerScore = TextComponent(
        'Score: 0',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
          config: TextPaintConfig(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
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
        textRenderer: TextPaint(
          config: TextPaintConfig(
            color: Colors.white,
            fontSize: 12,
            fontFamily: 'BungeeInline',
          ),
        ),
      );

      // Anchor to top right as we want the top right
      // corner of this component to be at a specific position.
      _playerHealth.anchor = Anchor.topRight;

      // Setting isHud to true makes sure that this component
      // does not get affected by camera's transformations.
      _playerHealth.isHud = true;

      add(_playerHealth);

      // Set this to true so that we do not initilize
      // everything again in the same session.
      _isAlreadyLoaded = true;
    }
  }

  // This method gets called when game instance gets attached
  // to Flutter's widget tree.
  @override
  void onAttach() {
    if (buildContext != null) {
      // Get the PlayerData from current build context without registering a listener.
      final playerData = Provider.of<PlayerData>(buildContext!, listen: false);
      // Update the current spaceship type of player.
      _player.setSpaceshipType(playerData.spaceshipType);
    }
    _audioPlayerComponent.playBgm('9. Space Invaders.wav');
    super.onAttach();
  }

  @override
  void onDetach() {
    _audioPlayerComponent.stopBgm();
    super.onDetach();
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

    /// Display [GameOverMenu] when [Player.health] becomes
    /// zero and camera stops shaking.
    if (_player.health <= 0 && (!camera.shaking)) {
      this.pauseEngine();
      this.overlays.remove(PauseButton.ID);
      this.overlays.add(GameOverMenu.ID);
    }
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

  // This method handles state of app and pauses
  // the game when necessary.
  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (this._player.health > 0) {
          this.pauseEngine();
          this.overlays.remove(PauseButton.ID);
          this.overlays.add(PauseMenu.ID);
        }
        break;
    }

    super.lifecycleStateChange(state);
  }

  // Adds given command to command list.
  void addCommand(Command command) {
    _addLaterCommandList.add(command);
  }

  // Resets the game to inital state. Should be called
  // while restarting and exiting the game.
  void reset() {
    // First reset player, enemy manager and power-up manager .
    _player.reset();
    _enemyManager.reset();
    _powerUpManager.reset();

    // Now remove all the enemies, bullets and power ups
    // from the game world. Note that, we are not calling
    // Enemy.destroy() because it will unnecessarily
    // run explosion effect and increase players score.
    components.whereType<Enemy>().forEach((enemy) {
      enemy.remove();
    });

    components.whereType<Bullet>().forEach((bullet) {
      bullet.remove();
    });

    components.whereType<PowerUp>().forEach((powerUp) {
      powerUp.remove();
    });
  }
}
