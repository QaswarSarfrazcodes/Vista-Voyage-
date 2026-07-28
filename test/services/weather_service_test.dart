import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripline/services/weather_service.dart';

void main() {
  test('getCurrentWeather parses a clear-sky (code 0) response', () async {
    final mockClient = MockClient((request) async => http.Response(
      '{"current_weather":{"temperature":22.5,"weathercode":0}}', 200));
    final result = await WeatherService.getCurrentWeather(48.85, 2.35, client: mockClient);
    expect(result, isNotNull);
    expect(result!.tempC, 22.5);
    expect(result.description, 'Clear sky');
    expect(result.icon, IconDataCode.sunny);
  });

  test('getCurrentWeather returns null on a non-200 response', () async {
    final mockClient = MockClient((request) async => http.Response('Server error', 500));
    final result = await WeatherService.getCurrentWeather(48.85, 2.35, client: mockClient);
    expect(result, null);
  });

  test('getCurrentWeather returns null on malformed JSON rather than throwing', () async {
    final mockClient = MockClient((request) async => http.Response('not json', 200));
    final result = await WeatherService.getCurrentWeather(48.85, 2.35, client: mockClient);
    expect(result, null);
  });

  test(
    'documents the code-40 mismatch flagged in data.md: text says "Foggy" '
    '(<=48 bucket) but the icon still maps to the rainy bucket (<=67), so the '
    'two are not aligned 1:1 for codes in the 4-48 range',
    () async {
      final mockClient = MockClient((request) async => http.Response(
        '{"current_weather":{"temperature":15.0,"weathercode":40}}', 200));
      final result = await WeatherService.getCurrentWeather(48.85, 2.35, client: mockClient);
      expect(result!.description, 'Foggy');
      expect(result.icon, IconDataCode.rainy);
    },
  );
}
