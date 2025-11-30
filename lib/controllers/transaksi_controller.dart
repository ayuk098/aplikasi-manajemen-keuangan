import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/transaksi_model.dart';
import 'dompet_controller.dart';
import '../services/notification_service.dart';

class TransaksiController extends ChangeNotifier {
  final _uuid = const Uuid();
  late Box<TransaksiModel> _transaksiBox;

  final String currentUserId;
  final DompetController dompetController;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TransaksiController(this.currentUserId, this.dompetController) {
    _transaksiBox = Hive.box<TransaksiModel>('transaksi');
  }

  List<TransaksiModel> get semuaTransaksi {
    final list = _transaksiBox.values
        .where((t) => t.userId == currentUserId)
        .toList();

    list.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return list;
  }

  double get totalPemasukan => _transaksiBox.values
      .where((t) => t.tipe == "pemasukan" && t.userId == currentUserId)
      .fold(0.0, (sum, t) => sum + t.jumlah);

  double get totalPengeluaran => _transaksiBox.values
      .where((t) => t.tipe == "pengeluaran" && t.userId == currentUserId)
      .fold(0.0, (sum, t) => sum + t.jumlah);

  double get sisaUang => totalPemasukan - totalPengeluaran;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  // ==============================
  //  SIMPAN TRANSAKSI + NOTIF
  // ==============================
  Future<void> simpanTransaksi({
    required String deskripsi,
    required String jumlahText,
    required DateTime tanggal,
    required String tipe,
    required String kategoriId,
    required String dompetId,
  }) async {
    _setLoading(true);

    try {
      if (kategoriId.isEmpty) throw StateError('Kategori harus dipilih');
      if (dompetId.isEmpty) throw StateError('Dompet harus dipilih');

      final jumlah = double.tryParse(jumlahText.replaceAll(',', '').trim());
      if (jumlah == null) throw FormatException('Jumlah tidak valid');
      if (jumlah <= 0) throw FormatException('Jumlah harus lebih dari 0');

      final transaksi = TransaksiModel(
        id: _uuid.v4(),
        jumlah: jumlah,
        kategoriId: kategoriId,
        dompetId: dompetId,
        tanggal: tanggal,
        deskripsi: deskripsi.trim(),
        tipe: tipe,
        userId: currentUserId,
      );

      await _transaksiBox.add(transaksi);

      if (tipe == "pemasukan") {
        dompetController.tambahSaldo(dompetId, jumlah);
      } else {
        dompetController.kurangiSaldo(dompetId, jumlah);
      }

      // 🔥 KIRIM NOTIFIKASI
      await NotificationService.showNotification(
        "Transaksi berhasil",
        "${tipe == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran'} "
        "Rp ${jumlah.toStringAsFixed(0)} telah ditambahkan",
      );

      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> hapusTransaksi(String id) async {
    final list = _transaksiBox.values.toList();
    final idx = list.indexWhere((t) => t.id == id && t.userId == currentUserId);

    if (idx != -1) {
      final transaksi = list[idx];

      if (transaksi.tipe == "pemasukan") {
        dompetController.kurangiSaldo(transaksi.dompetId, transaksi.jumlah);
      } else {
        dompetController.tambahSaldo(transaksi.dompetId, transaksi.jumlah);
      }

      await _transaksiBox.deleteAt(idx);
      notifyListeners();
    }
  }

  Future<void> updateTransaksi(String id, TransaksiModel updated) async {
    final list = _transaksiBox.values.toList();
    final idx = list.indexWhere((t) => t.id == id && t.userId == currentUserId);

    if (idx != -1) {
      final old = list[idx];

      if (old.tipe == "pemasukan") {
        dompetController.kurangiSaldo(old.dompetId, old.jumlah);
      } else {
        dompetController.tambahSaldo(old.dompetId, old.jumlah);
      }

      if (updated.tipe == "pemasukan") {
        dompetController.tambahSaldo(updated.dompetId, updated.jumlah);
      } else {
        dompetController.kurangiSaldo(updated.dompetId, updated.jumlah);
      }

      await _transaksiBox.putAt(idx, updated);
      notifyListeners();
    }
  }
}
