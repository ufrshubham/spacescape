import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

// This class is responsible for initializing and running the game-loop.
class SpacescapeGame extends BaseGame {
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

    SpriteComponent player = SpriteComponent(
      sprite: spriteSheet.getSpriteById(6),
      size: Vector2(64, 64),
      position: viewport.canvasSize / 2,
    );

    // Makes sure that the sprite is centered.
    player.anchor = Anchor.center;

    add(player);
  }
}
