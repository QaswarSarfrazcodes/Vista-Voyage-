// lib/services/local_pulse_service.dart
// Reuses WeatherService (already have) + adds a lightweight air-quality layer.
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocalPulseService {
  /// Uses Open-Meteo's air quality endpoint (free, no key).
  static Future<Map<String, dynamic>?> getSafetySnapshot(double lat, double lon, {http.Client? client}) async {
    final c = client ?? http.Client();
    try {
      final uri = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$lat&longitude=$lon&current=us_aqi');
      final res = await c.get(uri).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      final aqi = data['current']?['us_aqi'];
      return {
        'aqi': aqi,
        'aqiLabel': aqi == null ? 'Unknown' : (aqi <= 50 ? 'Good' : aqi <= 100 ? 'Moderate' : 'Unhealthy for sensitive groups'),
      };
    } catch (_) {
      return null;
    }
  }
}
