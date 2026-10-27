// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnboardingHiveAdapter extends TypeAdapter<OnboardingHive> {
  @override
  final typeId = 3;

  @override
  OnboardingHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingHive(
      isOnboarded: fields[0] as bool,
      languageString: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingHive obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.isOnboarded)
      ..writeByte(1)
      ..write(obj.languageString);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
