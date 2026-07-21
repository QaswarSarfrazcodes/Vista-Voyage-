// lib/services/ai_service.dart
// Groq AI service — OpenAI-compatible API for fast LLM inference.
// Called by AiScreen to generate travel itineraries and answer questions.

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/destination_model.dart';

class AiService {
  static const _apiKey =
      'gsk_tnal7m0QFNNON5bBvOA4WGdyb3FYrbqRv6Od0QFwkiAZOIGlpaz77g6k8n9q3v'; // Groq API key (replace with your own)

  // Groq's OpenAI-compatible endpoint
  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  // Model — fast & free on Groq
  static const _model = 'llama3-8b-8192';

  Future<String> askAI(DestinationModel dest, String userMessage) async {
    try {
      final response = await http
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
    } on Exception catch (e) {
      return 'Could not connect to AI assistant. '
          'Please check your internet and try again.\n\nError: $e';
    }
  }
}
