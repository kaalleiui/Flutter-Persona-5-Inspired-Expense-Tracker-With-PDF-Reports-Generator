// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confidant.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfidantAdapter extends TypeAdapter<Confidant> {
  @override
  final int typeId = 3;

  @override
  Confidant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Confidant(
      id: fields[0] as String,
      name: fields[1] as String,
      rank: fields[2] as int,
      description: fields[3] as String,
      iconCode: fields[4] as int,
      colorValue: fields[5] as int,
      abilities: (fields[6] as List).cast<String>(),
      pointsToNextRank: fields[7] as int,
      currentPoints: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Confidant obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rank)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.iconCode)
      ..writeByte(5)
      ..write(obj.colorValue)
      ..writeByte(6)
      ..write(obj.abilities)
      ..writeByte(7)
      ..write(obj.pointsToNextRank)
      ..writeByte(8)
      ..write(obj.currentPoints);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfidantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ConfidantSystemAdapter extends TypeAdapter<ConfidantSystem> {
  @override
  final int typeId = 4;

  @override
  ConfidantSystem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfidantSystem(
      confidants: (fields[0] as List).cast<Confidant>(),
      activeConfidantId: fields[1] as String,
      totalSavings: fields[2] as int,
      totalDaysStreak: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ConfidantSystem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.confidants)
      ..writeByte(1)
      ..write(obj.activeConfidantId)
      ..writeByte(2)
      ..write(obj.totalSavings)
      ..writeByte(3)
      ..write(obj.totalDaysStreak);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfidantSystemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
