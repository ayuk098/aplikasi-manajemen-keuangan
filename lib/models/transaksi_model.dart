import 'package:hive/hive.dart';

part 'transaksi_model.g.dart';

@HiveType(typeId: 3)
class TransaksiModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  double jumlah;

  @HiveField(2)
  String kategoriId;

  @HiveField(3)
  String dompetId;

  @HiveField(4)
  DateTime tanggal;

  @HiveField(5)
  String deskripsi;

  @HiveField(6)
  String tipe; // pemasukan / pengeluaran

  @HiveField(7) // <<< FIELD BARU
  String userId; // Kunci pembeda antar pengguna

  TransaksiModel({
    required this.id,
    required this.jumlah,
    required this.kategoriId,
    required this.dompetId,
    required this.tanggal,
    required this.deskripsi,
    required this.tipe,
    required this.userId, // <<< TAMBAH PADA KONSTRUKTOR
  });
}

extension TransaksiCopy on TransaksiModel {
  TransaksiModel copyWith({
    double? jumlah,
    String? kategoriId,
    String? dompetId,
    DateTime? tanggal,
    String? deskripsi,
    String? tipe,
    // Tidak perlu copy userId
  }) {
    return TransaksiModel(
      id: id,
      jumlah: jumlah ?? this.jumlah,
      kategoriId: kategoriId ?? this.kategoriId,
      dompetId: dompetId ?? this.dompetId,
      tanggal: tanggal ?? this.tanggal,
      deskripsi: deskripsi ?? this.deskripsi,
      tipe: tipe ?? this.tipe,
      userId: userId, // Pastikan userId selalu dipertahankan
    );
  }
}