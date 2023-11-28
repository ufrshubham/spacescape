import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:spacescape/widgets/overlays/game_over_menu.dart';

import '../game/game.dart';
import '../widgets/overlays/pause_button.dart';
import '../widgets/overlays/pause_menu.dart';

// Creating this as a file private object so as to
// avoid unwanted rebuilds of the whole game object.
SpacescapeGame _spacescapeGame = SpacescapeGame();

// This class represents the actual game screen
// where all the action happens.
class GamePlay extends StatelessWidget {
  const GamePlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // WillPopScope provides us a way to decide if
      // this widget should be poped or not when user
      // presses the back button.
      body: PopScope(
        canPop: false,
        // GameWidget is useful to inject the underlying
        // widget of any class extending from Flame's Game class.
        child: GameWidget(
          game: _spacescapeGame,
          // Initially only pause button overlay will be visible.
          initialActiveOverlays: const [PauseButton.id],
          overlayBuilderMap: {
            PauseButton.id: (BuildContext context, SpacescapeGame game) =>
                PauseButton(
                  game: game,
                ),
            PauseMenu.id: (BuildContext context, SpacescapeGame game) =>
                PauseMenu(
                  game: game,
                ),
            GameOverMenu.id: (BuildContext context, SpacescapeGame game) =>
                GameOverMenu(
                  game: game,
                ),
          },
        ),
      ),
    );
  }
}
