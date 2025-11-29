// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dompet_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DompetModelAdapter extends TypeAdapter<DompetModel> {
  @override
  final int typeId = 2;

  @override
  DompetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DompetModel(
      id: fields[0] as String,
      nama: fields[1] as String,
      saldoAwal: fields[2] as double,
      userId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DompetModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.saldoAwal)
      ..writeByte(3)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DompetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
