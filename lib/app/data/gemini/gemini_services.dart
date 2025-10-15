import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GeminiService {
  final GenerativeModel _model = FirebaseAI.googleAI(
    auth: FirebaseAuth.instance,
  ).generativeModel(model: 'gemini-2.5-flash');

  Future<Map<String, String>> generateTask() async {
    final model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',

      generationConfig: GenerationConfig(responseMimeType: 'application/json'),
    );

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

    final response = await model.generateContent([Content.text(prompt)]);

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

  //   Future<void> askGemini() async {
  // // Initialize the Gemini Developer API backend service
  // // Create a `GenerativeModel` instance with a model that supports your use case
  //     final model =
  //     FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');
  //
  // // Provide a prompt that contains text
  //     final prompt = [Content.text('Write 40 words a story about a magic backpack.')];
  //
  // // To generate text output, call generateContent with the text input
  //     final response = await model.generateContent(prompt);
  //     print("log the gemini response is: ${response.text}");
  //   }
}
