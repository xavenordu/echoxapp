// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sentiment.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SentimentAdapter extends TypeAdapter<Sentiment> {
  @override
  final int typeId = 3;

  @override
  Sentiment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sentiment(
      score: fields[0] as double,
      label: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sentiment obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.score)
      ..writeByte(1)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SentimentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
