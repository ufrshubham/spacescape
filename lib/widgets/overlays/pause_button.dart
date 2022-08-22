import 'package:flutter/material.dart';

import '../../game/game.dart';
import 'pause_menu.dart';

// This class represents the pause button overlay.
class PauseButton extends StatelessWidget {
  static const String id = 'PauseButton';
  final SpacescapeGame gameRef;

  const PauseButton({Key? key, required this.gameRef}) : super(key: key);

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
          gameRef.pauseEngine();
          gameRef.overlays.add(PauseMenu.id);
          gameRef.overlays.remove(PauseButton.id);
        },
      ),
    );
  }
}
