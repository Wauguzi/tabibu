// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ordered_test_hive.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderedTestHiveAdapter extends TypeAdapter<OrderedTestHive> {
  @override
  final typeId = 5;

  @override
  OrderedTestHive read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderedTestHive(
      labTestId: fields[0] as String,
      testTypeId: fields[1] as String,
      testTypeName: fields[2] as String,
      name: fields[3] as String,
      priceKes: (fields[4] as num).toInt(),
      isPriceEstimate: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OrderedTestHive obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.labTestId)
      ..writeByte(1)
      ..write(obj.testTypeId)
      ..writeByte(2)
      ..write(obj.testTypeName)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.priceKes)
      ..writeByte(5)
      ..write(obj.isPriceEstimate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderedTestHiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
