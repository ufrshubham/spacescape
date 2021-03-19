import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:spacescape/game/game.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // This opens the app in fullscreen mode.
  Flame.device.fullScreen();

  runApp(
    // GameWidget is useful to inject the underlying
    // widget of any class extending from Flame's Game class.
    GameWidget(
      game: SpacescapeGame(),
    ),
  );
}
