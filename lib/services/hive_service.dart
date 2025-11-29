import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/kategori_model.dart';
import '../models/dompet_model.dart';
import '../models/transaksi_model.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.openBox<UserModel>('users');
    await Hive.openBox('session');
    await Hive.openBox<KategoriModel>('kategori');
    await Hive.openBox<DompetModel>('dompet');
    await Hive.openBox<TransaksiModel>('transaksi');
    await Hive.openBox('flags'); 
  }
}
