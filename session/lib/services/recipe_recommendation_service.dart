import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/recipe.dart';
import '../models/detection_result.dart';

class RecipeRecommendationService {
  static const String _model = 'gpt-4.1-mini';

  Future<List<Recipe>> getRecipeRecommendations(
    DetectionResult detectionResult, {
    String? cuisinePreference,
    String? difficultyPreference,
    int maxRecipes = 3,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      String prompt = _buildRecipePrompt(
        detectionResult,
        cuisinePreference,
        difficultyPreference,
        maxRecipes,
      );

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

      return _parseRecipeResponse(content.trim());
    } catch (e) {
      throw Exception('Error al generar recomendaciones: ${e.toString()}');
    }
  }

  Future<List<Recipe>> getRecipesFromIngredients(
    List<String> ingredientNames, {
    String? cuisinePreference,
    String? difficultyPreference,
    int maxRecipes = 3,
  }) async {
    try {
      final apiKey = dotenv.env['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('API key not found. Please add OPENAI_API_KEY to your .env file.');
      }

      String prompt = _buildSimpleRecipePrompt(
        ingredientNames,
        cuisinePreference,
        difficultyPreference,
        maxRecipes,
      );

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

      return _parseRecipeResponse(content.trim());
    } catch (e) {
      throw Exception('Error al generar recetas: ${e.toString()}');
    }
  }

  Future<String?> persistRecipes(String uploadId, List<Recipe> recipes) async {
    try {
      final client = Supabase.instance.client;
      final rows = recipes.map((r) => {
        'upload_id': uploadId,
        'title': r.name,
        'description': r.description,
        'ingredients_list': r.ingredients,
        'steps': r.steps.map((s) => s.toJson()).toList(),
        'image_url': r.imageUrl,
      }).toList();

      final insertResp = await client.from('recipes').insert(rows).select('id');
      if (insertResp is List && insertResp.isNotEmpty) {
        // Return the first recipe id as a reference
        return insertResp.first['id'] as String?;
      }
      return null;
    } catch (e) {
      // No bloquear flujo si falla la persistencia
      return null;
    }
  }

  String _buildRecipePrompt(
    DetectionResult detectionResult,
    String? cuisinePreference,
    String? difficultyPreference,
    int maxRecipes,
  ) {
    String prompt = '''
Basándote en los siguientes ingredientes y utensilios detectados, genera $maxRecipes recetas completas y detalladas.

INGREDIENTES DISPONIBLES:
${detectionResult.ingredients.map((i) => '- ${i.name} (${i.category})').join('\n')}

UTENSILIOS DISPONIBLES:
${detectionResult.utensils.map((u) => '- ${u.name} (${u.category})').join('\n')}
''';

    if (cuisinePreference != null && cuisinePreference.isNotEmpty) {
      prompt += '\nPREFERENCIA DE COCINA: $cuisinePreference';
    }

    if (difficultyPreference != null && difficultyPreference.isNotEmpty) {
      prompt += '\nNIVEL DE DIFICULTAD PREFERIDO: $difficultyPreference';
    }

    prompt += '''

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido en el siguiente formato exacto:

{
  "recipes": [
    {
      "id": "recipe_1",
      "name": "Nombre de la receta",
      "description": "Descripción breve y atractiva de la receta",
      "ingredients": [
        "cantidad + ingrediente (ej: 2 tomates grandes)",
        "1 cebolla mediana",
        "sal al gusto"
      ],
      "steps": [
        {
          "stepNumber": 1,
          "instruction": "Instrucción detallada del paso",
          "duration": 5,
          "tip": "Consejo opcional para este paso",
          "requiredIngredients": ["tomate", "cebolla"],
          "requiredUtensils": ["cuchillo", "tabla de cortar"]
        }
      ],
      "preparationTime": 15,
      "cookingTime": 30,
      "servings": 4,
      "difficulty": "Fácil",
      "cuisine": "Mexicana",
      "tags": ["saludable", "vegetariano"],
      "requiredUtensils": ["sartén", "cuchillo", "tabla de cortar"]
    }
  ]
}

REGLAS IMPORTANTES:
- Usa principalmente los ingredientes detectados
- Si faltan ingredientes básicos (sal, aceite, etc.), inclúyelos en la lista
- Los tiempos deben ser en minutos
- La dificultad debe ser: ${RecipeDifficulty.allLevels.join(', ')}
- El tipo de cocina debe ser: ${CuisineType.allTypes.join(', ')}
- Incluye pasos detallados y prácticos
- Considera los utensilios disponibles
- Cada paso debe tener instrucciones claras
''';

    return prompt;
  }

  String _buildSimpleRecipePrompt(
    List<String> ingredientNames,
    String? cuisinePreference,
    String? difficultyPreference,
    int maxRecipes,
  ) {
    String prompt = '''
Genera $maxRecipes recetas completas usando principalmente estos ingredientes:

INGREDIENTES PRINCIPALES:
${ingredientNames.map((name) => '- $name').join('\n')}
''';

    if (cuisinePreference != null && cuisinePreference.isNotEmpty) {
      prompt += '\nPREFERENCIA DE COCINA: $cuisinePreference';
    }

    if (difficultyPreference != null && difficultyPreference.isNotEmpty) {
      prompt += '\nNIVEL DE DIFICULTAD PREFERIDO: $difficultyPreference';
    }

    prompt += '''

IMPORTANTE: Responde ÚNICAMENTE con un JSON válido en el siguiente formato exacto:

{
  "recipes": [
    {
      "id": "recipe_1",
      "name": "Nombre de la receta",
      "description": "Descripción breve y atractiva de la receta",
      "ingredients": [
        "cantidad + ingrediente (ej: 2 tomates grandes)",
        "1 cebolla mediana",
        "sal al gusto"
      ],
      "steps": [
        {
          "stepNumber": 1,
          "instruction": "Instrucción detallada del paso",
          "duration": 5,
          "tip": "Consejo opcional para este paso",
          "requiredIngredients": ["tomate", "cebolla"],
          "requiredUtensils": ["cuchillo", "tabla de cortar"]
        }
      ],
      "preparationTime": 15,
      "cookingTime": 30,
      "servings": 4,
      "difficulty": "Fácil",
      "cuisine": "Mexicana",
      "tags": ["saludable", "vegetariano"],
      "requiredUtensils": ["sartén", "cuchillo", "tabla de cortar"]
    }
  ]
}

REGLAS IMPORTANTES:
- Usa principalmente los ingredientes proporcionados
- Si faltan ingredientes básicos (sal, aceite, etc.), inclúyelos en la lista
- Los tiempos deben ser en minutos
- La dificultad debe ser: ${RecipeDifficulty.allLevels.join(', ')}
- El tipo de cocina debe ser: ${CuisineType.allTypes.join(', ')}
- Incluye pasos detallados y prácticos
- Cada paso debe tener instrucciones claras
''';

    return prompt;
  }

  List<Recipe> _parseRecipeResponse(String responseText) {
    try {
      String cleanedResponse = _extractJsonFromResponse(responseText);
      final Map<String, dynamic> jsonResponse = json.decode(cleanedResponse);

      final List<Recipe> recipes = [];

      if (jsonResponse['recipes'] != null) {
        for (var recipeJson in jsonResponse['recipes']) {
          try {
            recipes.add(Recipe.fromJson(recipeJson));
          } catch (e) {
            print('Error parsing recipe: $e');
          }
        }
      }

      return recipes;
    } catch (e) {
      throw Exception('Error al parsear las recetas: ${e.toString()}');
    }
  }

  String _extractJsonFromResponse(String response) {
    final jsonStart = response.indexOf('{');
    final jsonEnd = response.lastIndexOf('}');

    if (jsonStart == -1 || jsonEnd == -1 || jsonStart >= jsonEnd) {
      throw Exception('No se encontró JSON válido en la respuesta');
    }

    return response.substring(jsonStart, jsonEnd + 1);
  }

  // Método auxiliar para filtrar recetas por dificultad
  List<Recipe> filterRecipesByDifficulty(List<Recipe> recipes, String difficulty) {
    return recipes.where((recipe) => recipe.difficulty == difficulty).toList();
  }

  // Método auxiliar para filtrar recetas por tipo de cocina
  List<Recipe> filterRecipesByCuisine(List<Recipe> recipes, String cuisine) {
    return recipes.where((recipe) => recipe.cuisine == cuisine).toList();
  }

  // Método auxiliar para ordenar recetas por tiempo total
  List<Recipe> sortRecipesByTime(List<Recipe> recipes, {bool ascending = true}) {
    recipes.sort((a, b) => ascending 
        ? a.totalTime.compareTo(b.totalTime)
        : b.totalTime.compareTo(a.totalTime));
    return recipes;
  }
}