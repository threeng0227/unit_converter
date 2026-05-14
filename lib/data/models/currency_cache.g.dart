// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CurrencyCacheAdapter extends TypeAdapter<CurrencyCache> {
  @override
  final int typeId = 2;

  @override
  CurrencyCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CurrencyCache(
      rates: (fields[0] as Map).cast<String, double>(),
      fetchedAt: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CurrencyCache obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.rates)
      ..writeByte(1)
      ..write(obj.fetchedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrencyCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
