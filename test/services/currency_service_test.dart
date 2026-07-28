import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripline/services/currency_service.dart';

void main() {
  test('convert returns the parsed rate on a successful response', () async {
    final mockClient = MockClient((request) async =>
      http.Response('{"amount":100,"base":"USD","rates":{"PKR":27850.0}}', 200));
    final result = await CurrencyService.convert(100, 'USD', 'PKR', client: mockClient);
    expect(result, 27850.0);
  });

  test('convert returns null on a non-200 response', () async {
    final mockClient = MockClient((request) async => http.Response('Bad Request', 400));
    final result = await CurrencyService.convert(100, 'USD', 'PKR', client: mockClient);
    expect(result, null);
  });

  test('convert returns null on malformed JSON rather than throwing', () async {
    final mockClient = MockClient((request) async => http.Response('not json', 200));
    final result = await CurrencyService.convert(100, 'USD', 'PKR', client: mockClient);
    expect(result, null);
  });
}
