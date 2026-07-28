import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:tripline/models/destination_model.dart';
import 'package:tripline/services/ai_service.dart';

void main() {
  // AiService._apiKey reads dotenv.env['GROQ_API_KEY'] unconditionally when
  // building the Authorization header — even with a mocked http.Client, a
  // real .env was never loaded in the test environment, so dotenv throws
  // NotInitializedError before the mock client is ever reached. testLoad()
  // is flutter_dotenv's supported way to seed env values without touching
  // the filesystem.
  setUp(() => dotenv.testLoad(fileInput: 'GROQ_API_KEY=test-key-not-real'));

  const dest = DestinationModel(
    id: 'paris', name: 'Paris', country: 'France',
    imageUrl: 'https://x.com/p.jpg', description: 'City of Light', rating: 4.9);

  test('askAI returns the model content on a well-formed 200 response', () async {
    final mockClient = MockClient((request) async => http.Response(
      '{"choices":[{"message":{"content":"Visit the Eiffel Tower!"}}]}', 200));
    final result = await AiService(client: mockClient).askAI(dest, 'What should I see?');
    expect(result, 'Visit the Eiffel Tower!');
  });

  test('askAI returns a friendly message on non-200 (does not throw)', () async {
    final mockClient = MockClient((request) async => http.Response('Server error', 500));
    final result = await AiService(client: mockClient).askAI(dest, 'test');
    expect(result.contains('500'), true);
  });

  test(
    'FIXED (was a known gap in data.md): a 200 response with a missing '
    '"choices" array previously threw an uncaught TypeError (on Exception did '
    "not catch it, since TypeError isn't an Exception subtype in Dart). The "
    'catch clause is now a bare `catch (e)`, so this returns the same '
    'friendly fallback string instead of crashing the AI chat screen.',
    () async {
      final mockClient = MockClient((request) async => http.Response('{"unexpected":"shape"}', 200));
      final result = await AiService(client: mockClient).askAI(dest, 'test');
      expect(result.contains('Could not connect to AI assistant'), true);
    },
  );
}
