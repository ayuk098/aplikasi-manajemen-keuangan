import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class CurrencyController extends ChangeNotifier {
  late Box _sessionBox;

  String selectedCurrency = "IDR";
  double selectedRate = 1.0;

  CurrencyController() {
    _sessionBox = Hive.box('session');

    selectedCurrency = _sessionBox.get("currency", defaultValue: "IDR");
    selectedRate = _sessionBox.get("rate", defaultValue: 1.0);
  }

  // update mata uang
  Future<void> updateCurrency(String currency, double rate) async {
    selectedCurrency = currency;
    selectedRate = rate;

    await _sessionBox.put("currency", currency);
    await _sessionBox.put("rate", rate);

    notifyListeners();
  }

  // konversi idr
  double convertFromIdr(double amountInIdr) {
    return amountInIdr * selectedRate;
  }

  // format currency
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

  //icon mata uang
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
