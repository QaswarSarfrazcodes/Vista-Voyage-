// lib/services/landmark_scanner_service.dart
// Uses Groq's currently-active multimodal model. NOTE: llama-3.2-90b-vision-preview
// (originally spec'd) was deprecated by Groq on 2025-04-14, and its suggested
// replacement llama-4-scout-17b-16e-instruct was itself deprecated 2026-07-17.
// qwen/qwen3.6-27b is Groq's current recommended multimodal replacement as of
// this writing (console.groq.com/docs/deprecations) — re-verify before shipping,
// since Groq model names change and "Preview" models can be discontinued fast.
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LandmarkScannerService {
  static const _model = 'qwen/qwen3.6-27b';

  static Future<String> identifyLandmark(File image, {http.Client? client}) async {
    final c = client ?? http.Client();
    final bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);
    try {
      final response = await c
          .post(
            Uri.parse('https://api.groq.com/openai/v1/chat/completions'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${dotenv.env['GROQ_API_KEY']}',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {
                  'role': 'user',
                  'content': [
                    {'type': 'text', 'text': "What landmark or building is this? Give a 2-3 sentence fun fact if you recognize it, or say you're not sure."},
                    {'type': 'image_url', 'image_url': {'url': 'data:image/jpeg;base64,$base64Image'}},
                  ],
                },
              ],
              'max_tokens': 300,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        return 'Sorry, the scanner returned an error (${response.statusCode}). Please try again.';
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['choices'][0]['message']['content'] as String;
    } catch (_) {
      return 'Could not identify this. Try a clearer photo of the landmark.';
    }
  }
}
