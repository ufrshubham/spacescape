import 'package:flutter/material.dart';

import 'spaceship_details.dart';

// This class represents all the persistent data that we
// might want to store for tracking player progress.
class PlayerData extends ChangeNotifier {
  // The spaceship type of player's current spaceship.
  SpaceshipType spaceshipType;

  // List of all the spaceships owned by player.
  // Note that just storing their type is enough.
  final List<SpaceshipType> ownedSpaceships;

  // Highest player score so far.
  final int highScore;

  // Balance money.
  int money;

  // Keeps track of current score.
  // If game is not running, this will
  // represent score of last round.
  int currentScore = 0;

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

  /// Returns true if given [SpaceshipType] is owned by player.
  bool isOwned(SpaceshipType spaceshipType) {
    return this.ownedSpaceships.contains(spaceshipType);
  }

  /// Returns true if player has enough money to by given [SpaceshipType].
  bool canBuy(SpaceshipType spaceshipType) {
    return (this.money >= Spaceship.getSpaceshipByType(spaceshipType).cost);
  }

  /// Returns true if player's current spaceship type is same as given [SpaceshipType].
  bool isEquipped(SpaceshipType spaceshipType) {
    return (this.spaceshipType == spaceshipType);
  }

  /// Buys the given [SpaceshipType] if player has enough money and does not already own it.
  void buy(SpaceshipType spaceshipType) {
    if (canBuy(spaceshipType) && (!isOwned(spaceshipType))) {
      this.money -= Spaceship.getSpaceshipByType(spaceshipType).cost;
      this.ownedSpaceships.add(spaceshipType);
      notifyListeners();
    }
  }

  /// Sets the given [SpaceshipType] as the current spaceship type for player.
  void equip(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    notifyListeners();
  }
}
