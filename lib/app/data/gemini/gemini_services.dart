import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1/models/gemini-2.0-flash:generateContent';

  Future<Map<String, String>> generateTask() async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env');
    }

    final prompt = '''
      Generate a random to-do task.
      Return JSON strictly in this format:
      {
        "title": "<short title>",
        "description": "<short creative description>"
      }
      Do not include explanations or markdown formatting like ```json.
    ''';

    final response = await http.post(
      Uri.parse('$endpoint?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        String text = data['candidates'][0]['content']['parts'][0]['text'];
        text = text
            .replaceAll(RegExp(r'```json', caseSensitive: false), '')
            .replaceAll('```', '')
            .trim();

        final result = Map<String, String>.from(jsonDecode(text));
        return result;
      } catch (e) {
        throw Exception('Failed to parse Gemini response.');
      }
    } else {
      throw Exception(
        'Gemini request failed: ${response.statusCode} ${response.body}',
      );
    }
  }
}
