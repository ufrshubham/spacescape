import 'package:flutter/material.dart';

import '../../game/game.dart';
import 'pause_menu.dart';

// This class represents the pause button overlay.
class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final SpacescapeGame game;

  const PauseButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: TextButton(
        child: const Icon(
          Icons.pause_rounded,
          color: Colors.white,
        ),
        onPressed: () {
          game.pauseEngine();
          game.overlays.add(PauseMenu.id);
          game.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
