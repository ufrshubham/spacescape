// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spaceship_details.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SpaceshipTypeAdapter extends TypeAdapter<SpaceshipType> {
  @override
  final int typeId = 1;

  @override
  SpaceshipType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SpaceshipType.Canary;
      case 1:
        return SpaceshipType.Dusky;
      case 2:
        return SpaceshipType.Condor;
      case 3:
        return SpaceshipType.CXC;
      case 4:
        return SpaceshipType.Raptor;
      case 5:
        return SpaceshipType.RaptorX;
      case 6:
        return SpaceshipType.Albatross;
      case 7:
        return SpaceshipType.DK809;
      default:
        return SpaceshipType.Canary;
    }
  }

  @override
  void write(BinaryWriter writer, SpaceshipType obj) {
    switch (obj) {
      case SpaceshipType.Canary:
        writer.writeByte(0);
        break;
      case SpaceshipType.Dusky:
        writer.writeByte(1);
        break;
      case SpaceshipType.Condor:
        writer.writeByte(2);
        break;
      case SpaceshipType.CXC:
        writer.writeByte(3);
        break;
      case SpaceshipType.Raptor:
        writer.writeByte(4);
        break;
      case SpaceshipType.RaptorX:
        writer.writeByte(5);
        break;
      case SpaceshipType.Albatross:
        writer.writeByte(6);
        break;
      case SpaceshipType.DK809:
        writer.writeByte(7);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpaceshipTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
