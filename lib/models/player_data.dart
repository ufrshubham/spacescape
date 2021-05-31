import 'package:flutter/material.dart';

import 'spaceship_details.dart';

// This class represents all the persistent data that we
// might want to store for tracking player progress.
class PlayerData extends ChangeNotifier {
  // The spaceship type of player's current spaceship.
  final SpaceshipType spaceshipType;

  // List of all the spaceships owned by player.
  // Note that just storing their type is enough.
  final List<SpaceshipType> ownedSpaceships;

  // Highest player score so far.
  final int highScore;

  // Balance money.
  final int money;

  PlayerData({
    required this.spaceshipType,
    required this.ownedSpaceships,
    required this.highScore,
    required this.money,
  });

  /// Creates a new instace of [PlayerData] from given map.
  PlayerData.fromMap(Map<String, dynamic> map)
      : this.spaceshipType = map['currentSpaceshipType'],
        this.ownedSpaceships = map['ownedSpaceshipTypes']
            .map((e) => e as SpaceshipType) // Map out each element.
            .cast<SpaceshipType>() // Cast each element to SpaceshipType.
            .toList(), // Convert to a List<SpaceshipType>.
        this.highScore = map['highScore'],
        this.money = map['money'];

  // A default map which should be used for creating the
  // very first PlayerData instance when game is launched
  // for the first time.
  static Map<String, dynamic> defaultData = {
    'currentSpaceshipType': SpaceshipType.Canary,
    'ownedSpaceshipTypes': [SpaceshipType.Canary],
    'highScore': 0,
    'money': 0,
  };
}
