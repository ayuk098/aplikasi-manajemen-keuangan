import 'package:hive/hive.dart';

part 'kategori_model.g.dart';

@HiveType(typeId: 1)
class KategoriModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String tipe; 

  @HiveField(3) 
  String userId; 

  KategoriModel({
    required this.id,
    required this.nama,
    required this.tipe,
    required this.userId, 
  });
}