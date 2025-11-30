import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/dompet_model.dart';

class DompetController extends ChangeNotifier {
  final uuid = const Uuid();
  late Box<DompetModel> _dompetBox;

  final Box flagBox = Hive.box('flags');
  final String currentUserId;

  DompetController(this.currentUserId) {
    _dompetBox = Hive.box<DompetModel>('dompet');
    initDefaultDompet(); // <-- penting!
  }

  // Semua dompet milik user yang login
  List<DompetModel> get semuaDompet =>
      _dompetBox.values.where((d) => d.userId == currentUserId).toList();

  double get totalSaldo =>
      semuaDompet.fold(0.0, (sum, d) => sum + d.saldoAwal);

  // ========================
  //  DEFAULT DOMPET
  // ========================
  void initDefaultDompet() {
    final flagName = "defaultDompet_$currentUserId";
    if (flagBox.get(flagName) == true) return;

    final defaultDompet = DompetModel(
      id: uuid.v4(),
      nama: "Cash",
      saldoAwal: 0.0,
      userId: currentUserId,
    );

    _dompetBox.put(defaultDompet.id, defaultDompet);
    flagBox.put(flagName, true);

    notifyListeners();
  }

  // ========================
  // CRUD DOMPET
  // ========================
  void tambahDompet(String nama, double saldoAwal) {
    final newDompet = DompetModel(
      id: uuid.v4(),
      nama: nama,
      saldoAwal: saldoAwal,
      userId: currentUserId,
    );

    _dompetBox.put(newDompet.id, newDompet);
    notifyListeners();
  }

  void editDompet(String id, String nama, double saldoAwal) {
    final d = _dompetBox.get(id);
    if (d == null || d.userId != currentUserId) return;

    final updated = DompetModel(
      id: id,
      nama: nama,
      saldoAwal: saldoAwal,
      userId: currentUserId,
    );

    _dompetBox.put(id, updated);
    notifyListeners();
  }

  void hapusDompet(String id) {
    final d = _dompetBox.get(id);
    if (d == null || d.userId != currentUserId) return;

    _dompetBox.delete(id);
    notifyListeners();
  }

  // ========================
  // UPDATE SALDO (DARI TRANSAKSI)
  // ========================
  void tambahSaldo(String dompetId, double jumlah) {
    final d = _dompetBox.get(dompetId);
    if (d == null) return;

    final updated = DompetModel(
      id: d.id,
      nama: d.nama,
      saldoAwal: d.saldoAwal + jumlah,
      userId: d.userId,
    );

    _dompetBox.put(dompetId, updated);
    notifyListeners();
  }

  void kurangiSaldo(String dompetId, double jumlah) {
    final d = _dompetBox.get(dompetId);
    if (d == null) return;

    final updated = DompetModel(
      id: d.id,
      nama: d.nama,
      saldoAwal: d.saldoAwal - jumlah,
      userId: d.userId,
    );

    _dompetBox.put(dompetId, updated);
    notifyListeners();
  }
}
