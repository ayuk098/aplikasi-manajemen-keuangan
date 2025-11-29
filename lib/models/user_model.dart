import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel {
  @HiveField(0)
  String id;

  @HiveField(1)
  String nama;

  @HiveField(2)
  String email;

  @HiveField(3)
  String password;

  @HiveField(4)
  String? fotoPath;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    this.fotoPath,
  });
}
