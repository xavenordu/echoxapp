// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OnboardingStatusAdapter extends TypeAdapter<OnboardingStatus> {
  @override
  final int typeId = 4;

  @override
  OnboardingStatus read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OnboardingStatus(
      completed: fields[0] as bool,
      useCloudBackup: fields[1] as bool,
      completedAt: fields[2] as DateTime?,
      consentGiven: fields[3] as bool,
      darkMode: fields[4] as bool,
      notificationsEnabled: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, OnboardingStatus obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.completed)
      ..writeByte(1)
      ..write(obj.useCloudBackup)
      ..writeByte(2)
      ..write(obj.completedAt)
      ..writeByte(3)
      ..write(obj.consentGiven)
      ..writeByte(4)
      ..write(obj.darkMode)
      ..writeByte(5)
      ..write(obj.notificationsEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OnboardingStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
