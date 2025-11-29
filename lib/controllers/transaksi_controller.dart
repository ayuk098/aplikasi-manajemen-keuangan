import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/transaksi_model.dart';
import 'dompet_controller.dart';

class TransaksiController extends ChangeNotifier {
  final _uuid = const Uuid();
  late Box<TransaksiModel> _transaksiBox;

  final String currentUserId;
  final DompetController dompetController;

  TransaksiController(this.currentUserId, this.dompetController) {
    _transaksiBox = Hive.box<TransaksiModel>('transaksi');
  }

  // =========================
  //   GETTER TRANSAKSI
  // =========================
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

  // =========================
  //   TAMBAH TRANSAKSI
  // =========================
  Future<void> tambahTransaksi({
    required double jumlah,
    required String kategoriId,
    required String dompetId,
    required String deskripsi,
    required String tipe,
    required DateTime tanggal,
  }) async {

    final transaksi = TransaksiModel(
      id: _uuid.v4(),
      jumlah: jumlah,
      kategoriId: kategoriId,
      dompetId: dompetId,
      tanggal: tanggal,
      deskripsi: deskripsi,
      tipe: tipe,
      userId: currentUserId,
    );

    // simpan transaksi
    await _transaksiBox.add(transaksi);

    // update saldo dompet
    if (tipe == "pemasukan") {
      dompetController.tambahSaldo(dompetId, jumlah);
    } else {
      dompetController.kurangiSaldo(dompetId, jumlah);
    }

    notifyListeners();
  }

  // =========================
  //   HAPUS TRANSAKSI
  // =========================
  Future<void> hapusTransaksi(String id) async {
    final list = _transaksiBox.values.toList();
    final index = list.indexWhere((t) => t.id == id && t.userId == currentUserId);

    if (index != -1) {
      final transaksi = list[index];

      // rollback saldo
      if (transaksi.tipe == "pemasukan") {
        dompetController.kurangiSaldo(transaksi.dompetId, transaksi.jumlah);
      } else {
        dompetController.tambahSaldo(transaksi.dompetId, transaksi.jumlah);
      }

      await _transaksiBox.deleteAt(index);
      notifyListeners();
    }
  }

  // =========================
  //   UPDATE TRANSAKSI
  // =========================
  Future<void> updateTransaksi(String id, TransaksiModel updated) async {
    final list = _transaksiBox.values.toList();
    final index = list.indexWhere((t) => t.id == id && t.userId == currentUserId);

    if (index != -1) {
      final old = list[index];

      // revert saldo lama
      if (old.tipe == "pemasukan") {
        dompetController.kurangiSaldo(old.dompetId, old.jumlah);
      } else {
        dompetController.tambahSaldo(old.dompetId, old.jumlah);
      }

      // apply saldo baru
      if (updated.tipe == "pemasukan") {
        dompetController.tambahSaldo(updated.dompetId, updated.jumlah);
      } else {
        dompetController.kurangiSaldo(updated.dompetId, updated.jumlah);
      }

      await _transaksiBox.putAt(index, updated);
      notifyListeners();
    }
  }
}
