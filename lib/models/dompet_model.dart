import 'package:hive/hive.dart';

part 'dompet_model.g.dart';

@HiveType(typeId: 2)
class DompetModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  double saldoAwal;

  @HiveField(3)
  String userId;

  DompetModel({
    required this.id,
    required this.nama,
    required this.saldoAwal,
    required this.userId, 
  });
}