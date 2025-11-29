import 'package:hive/hive.dart';

part 'kategori_model.g.dart';

@HiveType(typeId: 1)
class KategoriModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String tipe; // pemasukan / pengeluaran

  @HiveField(3) // <<< FIELD BARU
  String userId; // Kunci pembeda antar pengguna

  KategoriModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.userId, // <<< TAMBAH PADA KONSTRUKTOR
  });
}