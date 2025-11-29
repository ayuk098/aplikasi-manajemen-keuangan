// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaksi_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransaksiModelAdapter extends TypeAdapter<TransaksiModel> {
  @override
  final int typeId = 3;

  @override
  TransaksiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransaksiModel(
      id: fields[0] as String,
      jumlah: fields[1] as double,
      kategoriId: fields[2] as String,
      dompetId: fields[3] as String,
      tanggal: fields[4] as DateTime,
      deskripsi: fields[5] as String,
      tipe: fields[6] as String,
      userId: fields[7] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TransaksiModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.jumlah)
      ..writeByte(2)
      ..write(obj.kategoriId)
      ..writeByte(3)
      ..write(obj.dompetId)
      ..writeByte(4)
      ..write(obj.tanggal)
      ..writeByte(5)
      ..write(obj.deskripsi)
      ..writeByte(6)
      ..write(obj.tipe)
      ..writeByte(7)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransaksiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
