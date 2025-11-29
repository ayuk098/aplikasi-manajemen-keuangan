// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kategori_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KategoriModelAdapter extends TypeAdapter<KategoriModel> {
  @override
  final int typeId = 1;

  @override
  KategoriModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KategoriModel(
      id: fields[0] as String,
      nama: fields[1] as String,
      tipe: fields[2] as String,
      userId: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, KategoriModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.tipe)
      ..writeByte(3)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KategoriModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
