import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String apiKey = "96ba972f336ef90bfec6bbe6";
  static const String baseUrl = "https://v6.exchangerate-api.com/v6";

  static Future<double?> getRate(String targetCurrency) async {
    final url = Uri.parse("$baseUrl/$apiKey/latest/IDR");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data["conversion_rates"][targetCurrency] * 1.0;
    }
    return null;
  }
}
