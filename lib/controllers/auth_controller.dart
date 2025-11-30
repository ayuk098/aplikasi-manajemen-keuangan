import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../models/user_model.dart';

class AuthController extends ChangeNotifier {
  final _uuid = const Uuid();

  late Box<UserModel> _userBox;
  late Box _sessionBox;

  UserModel? currentUser;
  String selectedCurrency = "IDR";
  double selectedRate = 1.0;

  AuthController() {
    _userBox = Hive.box<UserModel>('users');
    _sessionBox = Hive.box('session');

    if (_sessionBox.get('userId') != null) {
      String savedId = _sessionBox.get('userId');

      try {
        currentUser = _userBox.values.firstWhere((u) => u.id == savedId);
      } catch (e) {
        currentUser = null;
      }
    }
    selectedCurrency = _sessionBox.get("currency", defaultValue: "IDR");
    selectedRate = _sessionBox.get("rate", defaultValue: 1.0);
  }

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

  bool checkSession() {
    return _sessionBox.get('userId') != null;
  }

  Future<void> updatePhoto(String path) async {
    if (currentUser == null) return;

    currentUser!.fotoPath = path;

    final index = _userBox.values
        .toList()
        .indexWhere((u) => u.id == currentUser!.id);

    if (index != -1) {
      await _userBox.putAt(index, currentUser!);
    }

    notifyListeners();
  }
  Future<void> updateCurrency(String currency, double rate) async {
    selectedCurrency = currency;
    selectedRate = rate;

    await _sessionBox.put("currency", currency);
    await _sessionBox.put("rate", rate);

    notifyListeners();
  }

  Future<void> logout() async {
    await _sessionBox.clear();
    currentUser = null;
    notifyListeners();
  }
  double convertFromIdr(double amountInIdr) {
    return amountInIdr * selectedRate;
  }
  String formatCurrency(double value) {
    final symbol = _symbolForCurrency(selectedCurrency);

    final bool isIdr = selectedCurrency == "IDR";
    final locale = isIdr ? "id_ID" : "en_US";
    final decimalDigits = isIdr ? 0 : 2;

    final formatter = NumberFormat.currency(
      locale: locale,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );

    return formatter.format(value);
  }

  String formatFromIdr(double amountInIdr) {
    final converted = convertFromIdr(amountInIdr);
    return formatCurrency(converted);
  }

  String _symbolForCurrency(String code) {
    switch (code) {
      case "IDR":
        return "Rp";
      case "USD":
        return "\$";
      case "EUR":
        return "€";
      case "SGD":
        return "S\$";
      case "JPY":
        return "¥";
      case "MYR":
        return "RM";
      case "AUD":
        return "A\$";
      default:
        return code;
    }
  }
}
