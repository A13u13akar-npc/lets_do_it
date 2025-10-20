import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeminiService {
  static final GenerativeModel _model = FirebaseAI.googleAI(
    auth: FirebaseAuth.instance,
  ).generativeModel(model: 'gemini-2.5-flash');

  static Future<Map<String, String>> generateTask() async {
    final prompt = '''
    You are a creative task generator. 
    Generate a unique, random to-do task each time. The task should vary in topic, tone, and style — 
    it can be practical, fun, weird, or imaginative.
    
    Return JSON strictly in this format:
    {
      "title": "<short title>",
      "description": "<short creative description>"
    }
    
    Rules:
    - Always produce something new and different.
    - Avoid repeating previous ideas.
    - Be spontaneous — the task can relate to productivity, learning, kindness, creativity, or anything else.
    - No explanations or markdown formatting.
    ''';

    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text;

    if (text == null || text.isEmpty) {
      throw Exception('Gemini returned empty response');
    }

    try {
      final cleanText = text
          .replaceAll(RegExp(r'```json', caseSensitive: false), '')
          .replaceAll('```', '')
          .trim();

      return Map<String, String>.from(jsonDecode(cleanText));
    } catch (e) {
      throw Exception('Failed to parse Gemini response: $e');
    }
  }
}
