import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

import 'spaceship_details.dart';

part 'player_data.g.dart';

// This class represents all the persistent data that we
// might want to store for tracking player progress.
@HiveType(typeId: 0)
class PlayerData extends ChangeNotifier with HiveObjectMixin {
  static const String PLAYER_DATA_BOX = 'PlayerDataBox';
  static const String PLAYER_DATA_KEY = 'PlayerData';

  // The spaceship type of player's current spaceship.
  @HiveField(0)
  SpaceshipType spaceshipType;

  // List of all the spaceships owned by player.
  // Note that just storing their type is enough.
  @HiveField(1)
  final List<SpaceshipType> ownedSpaceships;

  // Highest player score so far.
  @HiveField(2)
  late int _highScore;
  int get highScore => _highScore;

  // Balance money.
  @HiveField(3)
  int money;

  // Keeps track of current score.
  // If game is not running, this will
  // represent score of last round.
  int _currentScore = 0;

  int get currentScore => _currentScore;

  set currentScore(int newScore) {
    _currentScore = newScore;
    // While setting currentScore to a new value
    // also make sure to update highScore.
    if (_highScore < _currentScore) {
      _highScore = _currentScore;
    }
  }

  PlayerData({
    required this.spaceshipType,
    required this.ownedSpaceships,
    int highScore = 0,
    required this.money,
  }) {
    _highScore = highScore;
  }

  /// Creates a new instance of [PlayerData] from given map.
  PlayerData.fromMap(Map<String, dynamic> map)
      : this.spaceshipType = map['currentSpaceshipType'],
        this.ownedSpaceships = map['ownedSpaceshipTypes']
            .map((e) => e as SpaceshipType) // Map out each element.
            .cast<SpaceshipType>() // Cast each element to SpaceshipType.
            .toList(), // Convert to a List<SpaceshipType>.
        this._highScore = map['highScore'],
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

      // Saves player data to disk.
      this.save();
    }
  }

  /// Sets the given [SpaceshipType] as the current spaceship type for player.
  void equip(SpaceshipType spaceshipType) {
    this.spaceshipType = spaceshipType;
    notifyListeners();

    // Saves player data to disk.
    this.save();
  }
}
