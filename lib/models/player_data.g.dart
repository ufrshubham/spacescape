// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerDataAdapter extends TypeAdapter<PlayerData> {
  @override
  final int typeId = 0;

  @override
  PlayerData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerData(
      spaceshipType: fields[0] as SpaceshipType,
      ownedSpaceships: (fields[1] as List).cast<SpaceshipType>(),
      highScore: fields[2] as int,
      money: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.spaceshipType)
      ..writeByte(1)
      ..write(obj.ownedSpaceships)
      ..writeByte(2)
      ..write(obj.highScore)
      ..writeByte(3)
      ..write(obj.money);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
