// lib/services/weather_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherInfo {
  final double tempC;
  final String description;
  final IconDataCode icon;
  WeatherInfo({required this.tempC, required this.description, required this.icon});
}

enum IconDataCode { sunny, cloudy, rainy, snowy, stormy, unknown }

class WeatherService {
  /// [client] is injectable for testing; production callers should omit it.
  static Future<WeatherInfo?> getCurrentWeather(double lat, double lon, {http.Client? client}) async {
    final c = client ?? http.Client();
    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true');
      final res = await c.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final current = data['current_weather'];
      final code = current['weathercode'] as int;
      return WeatherInfo(
        tempC: (current['temperature'] as num).toDouble(),
        description: _describeCode(code),
        icon: _iconForCode(code),
      );
    } catch (_) {
      return null;
    }
  }

  static String _describeCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code <= 3) return 'Partly cloudy';
    if (code <= 48) return 'Foggy';
    if (code <= 67) return 'Rainy';
    if (code <= 77) return 'Snowy';
    if (code <= 82) return 'Rain showers';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static IconDataCode _iconForCode(int code) {
    if (code == 0) return IconDataCode.sunny;
    if (code <= 3) return IconDataCode.cloudy;
    if (code <= 67) return IconDataCode.rainy;
    if (code <= 77) return IconDataCode.snowy;
    if (code <= 99) return IconDataCode.stormy;
    return IconDataCode.unknown;
  }
}
