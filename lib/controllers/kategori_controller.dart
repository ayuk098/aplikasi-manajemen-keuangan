// kategori_controller.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/kategori_model.dart';
import 'package:uuid/uuid.dart';

class KategoriController extends ChangeNotifier {
  final uuid = const Uuid();
  final box = Hive.box<KategoriModel>('kategori');
  final flagBox = Hive.box('flags'); 
  final String currentUserId; 

  KategoriController(this.currentUserId); 
  List<KategoriModel> get semuaKategori => box.values
      .where((k) => k.userId == currentUserId)
      .toList();

  void initDefaultKategori() {
    final flagName = "defaultKategori_$currentUserId"; 
    final sudahBuat = flagBox.get(flagName);
    if (sudahBuat == true) return;
    _buatDefaultKategori();
  }

  void _buatDefaultKategori() {
    final pemasukanDefault = [
      "Gaji", "Bonus", "Usaha", "Proyek", "Investasi", "Hadiah",
    ];

    final pengeluaranDefault = [
      "Makan & Minum", "Belanja", "Transportasi", "Kesehatan", "Pendidikan", "Hiburan",
    ];

    for (final nama in pemasukanDefault) {
      final k = KategoriModel(
        id: uuid.v4(),
        nama: nama,
        tipe: "pemasukan",
        userId: currentUserId, 
      );
      box.put(k.id, k);
    }

    for (final nama in pengeluaranDefault) {
      final k = KategoriModel(
        id: uuid.v4(),
        nama: nama,
        tipe: "pengeluaran",
        userId: currentUserId, 
      );
      box.put(k.id, k);
    }

    final flagName = "defaultKategori_$currentUserId";
    flagBox.put(flagName, true); 

    notifyListeners();
  }


  void tambahKategori(String nama, String tipe) {
    final newKategori = KategoriModel(
      id: uuid.v4(),
      nama: nama,
      tipe: tipe,
      userId: currentUserId, 
    );

    box.put(newKategori.id, newKategori);
    notifyListeners();
  }

  void editKategori(String id, String nama, String tipe) {
    final kategori = box.get(id);
    if (kategori != null && kategori.userId == currentUserId) {
      final updated = KategoriModel(
        id: id,
        nama: nama,
        tipe: tipe,
        userId: currentUserId, 
      );
      box.put(id, updated);
      notifyListeners();
    }
  }

  void hapusKategori(String id) {
    final kategori = box.get(id);
    if (kategori != null && kategori.userId == currentUserId) {
      box.delete(id);
      notifyListeners();
    }
  }
}