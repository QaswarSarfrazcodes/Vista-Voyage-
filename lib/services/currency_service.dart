// lib/services/currency_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  /// Converts [amount] from [from] currency code (e.g. 'USD') to [to] (e.g. 'PKR').
  /// [client] is injectable for testing; production callers should omit it.
  static Future<double?> convert(double amount, String from, String to, {http.Client? client}) async {
    final c = client ?? http.Client();
    try {
      final uri = Uri.parse('https://api.frankfurter.app/latest?amount=$amount&from=$from&to=$to');
      final res = await c.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      return (data['rates'][to] as num).toDouble();
    } catch (_) {
      return null;
    }
  }
}
