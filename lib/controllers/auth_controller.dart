import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final _uuid = const Uuid();

  late Box<UserModel> _userBox;
  late Box _sessionBox;

  UserModel? currentUser;

  AuthController() {
    _userBox = Hive.box<UserModel>('users');
    _sessionBox = Hive.box('session');

    // Restore session
    if (_sessionBox.get('userId') != null) {
      String savedId = _sessionBox.get('userId');

      try {
        currentUser = _userBox.values.firstWhere((u) => u.id == savedId);
      } catch (e) {
        currentUser = null;
      }
    }
  }

  //register user
  Future<bool> register(String nama, String email, String password) async {
    final exists = _userBox.values.any((u) => u.email == email);
    if (exists) return false;

    final newUser = UserModel(
      id: _uuid.v4(),
      nama: nama,
      email: email,
      password: password,
    );

    await _userBox.add(newUser);
    return true;
  }

  // login user
  Future<bool> login(String email, String password) async {
    try {
      final user = _userBox.values.firstWhere(
        (u) => u.email == email && u.password == password,
      );

      currentUser = user;
      await _sessionBox.put('userId', user.id);

      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  //cek session
  bool checkSession() {
    return _sessionBox.get('userId') != null;
  }

  //update foto
  Future<void> updatePhoto(String path) async {
    if (currentUser == null) return;

    currentUser!.fotoPath = path;

    final index =
        _userBox.values.toList().indexWhere((u) => u.id == currentUser!.id);

    if (index != -1) {
      await _userBox.putAt(index, currentUser!);
    }

    notifyListeners();
  }

  // logout
  Future<void> logout() async {
    await _sessionBox.clear();
    currentUser = null;
    notifyListeners();
  }
}
