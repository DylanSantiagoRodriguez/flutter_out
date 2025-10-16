import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ingredient.dart';
import '../models/kitchen_utensil.dart';
import '../models/detection_result.dart';

class KitchenDetectionService {
  static const String _model = 'gpt-4.1-mini';
  
  Future<DetectionResult> detectFromImage(File imageFile, {String? additionalText}) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      final imageBytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(imageBytes);

      String prompt = _buildDetectionPrompt(additionalText);

      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.2,
          'response_format': { 'type': 'json_object' },
          'messages': [
            {
              'role': 'user',
              'content': [
                { 'type': 'text', 'text': prompt },
                {
                  'type': 'image_url',
                  'image_url': { 'url': 'data:image/jpeg;base64,$base64Image' }
                }
              ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? content = data['choices']?[0]?['message']?['content'];
      if (content == null || content.trim().isEmpty) {
        throw Exception('No se recibió respuesta del modelo');
      }

      return _parseDetectionResponse(content.trim(), additionalText);
    } catch (e) {
      throw Exception('Error en la detección: ${e.toString()}');
    }
  }

  Future<DetectionResult> detectFromText(String text) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      String prompt = _buildTextDetectionPrompt(text);

      final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'temperature': 0.2,
          'response_format': { 'type': 'json_object' },
          'messages': [
            {
              'role': 'user',
              'content': [ { 'type': 'text', 'text': prompt } ]
            }
          ]
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('OpenAI API error: ${response.statusCode} ${response.body}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      final String? content = data['choices']?[0]?['message']?['content'];
      if (content == null || content.trim().isEmpty) {
        throw Exception('No se recibió respuesta del modelo');
      }

      return _parseDetectionResponse(content.trim(), text);
    } catch (e) {
      throw Exception('Error en la detección de texto: ${e.toString()}');
    }
  }

  String _buildDetectionPrompt(String? additionalText) {
    String basePrompt = '''
Analiza esta imagen de cocina y detecta todos los ingredientes y utensilios de cocina visibles.

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido en el siguiente formato exacto:

{
  "ingredients": [
    {
      "name": "nombre del ingrediente",
      "category": "categoría del ingrediente",
      "confidence": 0.95,
      "description": "descripción opcional"
    }
  ],
  "utensils": [
    {
      "name": "nombre del utensilio",
      "category": "categoría del utensilio", 
      "confidence": 0.90,
      "description": "descripción opcional",
      "isEssential": true
    }
  ],
  "overallConfidence": 0.85
}

Categorías de ingredientes válidas: ${IngredientCategory.allCategories.join(', ')}
Categorías de utensilios válidas: ${UtensilCategory.allCategories.join(', ')}

- Confidence debe ser un número entre 0.0 y 1.0
- Solo incluye elementos que puedas identificar con confianza
- isEssential indica si el utensilio es esencial para cocinar
''';

    if (additionalText != null && additionalText.isNotEmpty) {
      basePrompt += '\n\nTexto adicional proporcionado: "$additionalText"';
      basePrompt += '\nConsidera también este texto para identificar ingredientes o utensilios mencionados.';
    }

    return basePrompt;
  }

  String _buildTextDetectionPrompt(String text) {
    return '''
Analiza el siguiente texto y extrae todos los ingredientes y utensilios de cocina mencionados:

"$text"

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido en el siguiente formato exacto:

{
  "ingredients": [
    {
      "name": "nombre del ingrediente",
      "category": "categoría del ingrediente",
      "confidence": 0.95,
      "description": "descripción opcional"
    }
  ],
  "utensils": [
    {
      "name": "nombre del utensilio",
      "category": "categoría del utensilio", 
      "confidence": 0.90,
      "description": "descripción opcional",
      "isEssential": true
    }
  ],
  "overallConfidence": 0.85
}

Categorías de ingredientes válidas: ${IngredientCategory.allCategories.join(', ')}
Categorías de utensilios válidas: ${UtensilCategory.allCategories.join(', ')}

- Confidence debe ser un número entre 0.0 y 1.0
- Solo incluye elementos mencionados explícita o implícitamente
- isEssential indica si el utensilio es esencial para cocinar
''';
  }

  DetectionResult _parseDetectionResponse(String responseText, String? additionalText) {
    try {
      // Limpiar la respuesta para extraer solo el JSON
      String cleanedResponse = _extractJsonFromResponse(responseText);
      
      final Map<String, dynamic> jsonResponse = json.decode(cleanedResponse);
      
      final List<Ingredient> ingredients = [];
      final List<KitchenUtensil> utensils = [];
      
      // Parsear ingredientes
      if (jsonResponse['ingredients'] != null) {
        for (var ingredientJson in jsonResponse['ingredients']) {
          try {
            ingredients.add(Ingredient.fromJson(ingredientJson));
          } catch (e) {
            print('Error parsing ingredient: $e');
          }
        }
      }
      
      // Parsear utensilios
      if (jsonResponse['utensils'] != null) {
        for (var utensilJson in jsonResponse['utensils']) {
          try {
            utensils.add(KitchenUtensil.fromJson(utensilJson));
          } catch (e) {
            print('Error parsing utensil: $e');
          }
        }
      }
      
      final double overallConfidence = 
          (jsonResponse['overallConfidence'] as num?)?.toDouble() ?? 0.5;
      
      return DetectionResult(
        ingredients: ingredients,
        utensils: utensils,
        additionalText: additionalText,
        detectionTime: DateTime.now(),
        overallConfidence: overallConfidence,
      );
    } catch (e) {
      throw Exception('Error al parsear la respuesta: ${e.toString()}');
    }
  }

  String _extractJsonFromResponse(String response) {
    // Buscar el JSON en la respuesta
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}');
    
    if (jsonStart == -1 || jsonEnd == -1 || jsonStart >= jsonEnd) {
      throw Exception('No se encontró JSON válido en la respuesta');
    }
    
    return response.substring(jsonStart, jsonEnd + 1);
  }
}