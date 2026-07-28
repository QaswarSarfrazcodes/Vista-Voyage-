// lib/services/ai_service.dart
// Groq AI service — OpenAI-compatible API for fast LLM inference.
// Called by AiScreen to generate travel itineraries and answer questions.

import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/destination_model.dart';

class AiService {
  static String get _apiKey => dotenv.env['GROQ_API_KEY']!;

  // Groq's OpenAI-compatible endpoint
  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // Model — llama3-8b-8192 was decommissioned by Groq; this is their
  // current recommended fast/free model as of the console quickstart.
  static const _model = 'openai/gpt-oss-120b';

  /// [client] is injectable for testing; production callers should omit it.
  final http.Client _client;
  AiService({http.Client? client}) : _client = client ?? http.Client();

  Future<String> askAI(DestinationModel dest, String userMessage) async {
    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are an expert travel guide specializing in '
                      '${dest.name}, ${dest.country}. '
                      'Give concise, friendly, practical travel advice. '
                      'Use emojis where appropriate to make responses engaging.',
                },
                {
                  'role': 'user',
                  'content': userMessage,
                },
              ],
              'max_tokens': 800,
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['choices'][0]['message']['content'] as String;
      } else {
        return 'Sorry, the AI returned an error (${response.statusCode}). '
            'Please try again in a moment.';
      }
    } catch (e) {
      // Bare catch (not `on Exception`) is deliberate: a 200 response with an
      // unexpected JSON shape (e.g. missing `choices`) throws a TypeError,
      // which is not an Exception subtype in Dart and was previously
      // uncaught, crashing the AI chat screen.
      return 'Could not connect to AI assistant. '
          'Please check your internet and try again.\n\nError: $e';
    }
  }

  /// Builds a full day-by-day itinerary in one call. Returns `null` on any
  /// network/parse failure so the caller can show a "couldn't generate, try
  /// again" state instead of crashing (same class of bug V8 found in
  /// [askAI]'s unguarded `choices[0]` access).
  Future<Map<String, dynamic>?> generateTripBlueprint({
    required List<DestinationModel> destinations,
    required int days,
    required String travelStyle,
  }) async {
    final destNames = destinations.map((d) => '${d.name}, ${d.country}').join('; ');
    try {
      final response = await _client
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'system',
                  'content':
                      'You are a travel planner. Respond ONLY with valid JSON, no markdown, '
                      'no preamble. Shape: {"days":[{"day":1,"title":"...","morning":"...",'
                      '"afternoon":"...","evening":"...","estimatedCost":"..."}]}',
                },
                {
                  'role': 'user',
                  'content': 'Build a $days-day $travelStyle itinerary covering: $destNames',
                },
              ],
              'max_tokens': 1500,
              'temperature': 0.5,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) return null;
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final content = data['choices'][0]['message']['content'] as String;
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }
}
