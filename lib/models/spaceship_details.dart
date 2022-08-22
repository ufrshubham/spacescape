// This class represents all the data
// which defines a spaceship.
import 'package:hive/hive.dart';

part 'spaceship_details.g.dart';

class Spaceship {
  // Name of the spaceship.
  final String name;

  // Cost of the spaceship.
  final int cost;

  // Cost of the spaceship.
  final double speed;

  // SpriteId to be used for displaying
  // this spaceship in game world.
  final int spriteId;

  // Path to the asset to be used for displaying
  // this spaceship outside game world.
  final String assetPath;

  // Level of the spaceship.
  final int level;

  const Spaceship({
    required this.name,
    required this.cost,
    required this.speed,
    required this.spriteId,
    required this.assetPath,
    required this.level,
  });

  /// Given a spaceshipType, this method returns a corresponding
  /// Spaceship object which holds all the details of that spaceship.
  static Spaceship getSpaceshipByType(SpaceshipType spaceshipType) {
    /// It is highly unlikely that it [spaceships] does not contain given [spaceshipType].
    /// But if that ever happens, we will just return data for [SpaceshipType.Canary].
    return spaceships[spaceshipType] ?? spaceships.entries.first.value;
  }

  /// This map holds all the meta-data of each [SpaceshipType].
  static const Map<SpaceshipType, Spaceship> spaceships = {
    SpaceshipType.canary: Spaceship(
      name: 'Canary',
      cost: 0,
      speed: 250,
      spriteId: 0,
      assetPath: 'assets/images/ship_A.png',
      level: 1,
    ),
    SpaceshipType.dusky: Spaceship(
      name: 'Dusky',
      cost: 100,
      speed: 400,
      spriteId: 1,
      assetPath: 'assets/images/ship_B.png',
      level: 2,
    ),
    SpaceshipType.condor: Spaceship(
      name: 'Condor',
      cost: 200,
      speed: 300,
      spriteId: 2,
      assetPath: 'assets/images/ship_C.png',
      level: 2,
    ),
    SpaceshipType.cXC: Spaceship(
      name: 'CXC',
      cost: 400,
      speed: 300,
      spriteId: 3,
      assetPath: 'assets/images/ship_D.png',
      level: 3,
    ),
    SpaceshipType.raptor: Spaceship(
      name: 'Raptor',
      cost: 550,
      speed: 300,
      spriteId: 4,
      assetPath: 'assets/images/ship_E.png',
      level: 3,
    ),
    SpaceshipType.raptorX: Spaceship(
      name: 'Raptor-X',
      cost: 700,
      speed: 350,
      spriteId: 5,
      assetPath: 'assets/images/ship_F.png',
      level: 3,
    ),
    SpaceshipType.albatross: Spaceship(
      name: 'Albatross',
      cost: 850,
      speed: 400,
      spriteId: 6,
      assetPath: 'assets/images/ship_G.png',
      level: 4,
    ),
    SpaceshipType.dK809: Spaceship(
      name: 'DK-809',
      cost: 1000,
      speed: 450,
      spriteId: 7,
      assetPath: 'assets/images/ship_H.png',
      level: 4,
    ),
  };
}

// This enum represents all the spaceship
// types available in this game.
@HiveType(typeId: 1)
enum SpaceshipType {
  @HiveField(0)
  canary,

  @HiveField(1)
  dusky,

  @HiveField(2)
  condor,

  @HiveField(3)
  cXC,

  @HiveField(4)
  raptor,

  @HiveField(5)
  raptorX,

  @HiveField(6)
  albatross,

  @HiveField(7)
  dK809,
}
