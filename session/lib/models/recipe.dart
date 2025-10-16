class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final int preparationTime; // en minutos
  final int cookingTime; // en minutos
  final int servings;
  final String difficulty;
  final String cuisine;
  final List<String> tags;
  final List<String> requiredUtensils;
  final String? imageUrl;

  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.preparationTime,
    required this.cookingTime,
    required this.servings,
    required this.difficulty,
    required this.cuisine,
    this.tags = const [],
    this.requiredUtensils = const [],
    this.imageUrl,
  });

  int get totalTime => preparationTime + cookingTime;

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: (json['steps'] as List)
          .map((step) => RecipeStep.fromJson(step as Map<String, dynamic>))
          .toList(),
      preparationTime: json['preparationTime'] as int,
      cookingTime: json['cookingTime'] as int,
      servings: json['servings'] as int,
      difficulty: json['difficulty'] as String,
      cuisine: json['cuisine'] as String,
      tags: List<String>.from(json['tags'] as List? ?? []),
      requiredUtensils: List<String>.from(json['requiredUtensils'] as List? ?? []),
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'steps': steps.map((step) => step.toJson()).toList(),
      'preparationTime': preparationTime,
      'cookingTime': cookingTime,
      'servings': servings,
      'difficulty': difficulty,
      'cuisine': cuisine,
      'tags': tags,
      'requiredUtensils': requiredUtensils,
      'imageUrl': imageUrl,
    };
  }

  @override
  String toString() {
    return 'Recipe(name: $name, difficulty: $difficulty, totalTime: ${totalTime}min)';
  }
}

class RecipeStep {
  final int stepNumber;
  final String instruction;
  final int? duration; // en minutos, opcional
  final String? tip;
  final List<String> requiredIngredients;
  final List<String> requiredUtensils;

  const RecipeStep({
    required this.stepNumber,
    required this.instruction,
    this.duration,
    this.tip,
    this.requiredIngredients = const [],
    this.requiredUtensils = const [],
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      stepNumber: json['stepNumber'] as int,
      instruction: json['instruction'] as String,
      duration: json['duration'] as int?,
      tip: json['tip'] as String?,
      requiredIngredients: List<String>.from(json['requiredIngredients'] as List? ?? []),
      requiredUtensils: List<String>.from(json['requiredUtensils'] as List? ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'instruction': instruction,
      'duration': duration,
      'tip': tip,
      'requiredIngredients': requiredIngredients,
      'requiredUtensils': requiredUtensils,
    };
  }

  @override
  String toString() {
    return 'Step $stepNumber: $instruction';
  }
}

// Niveles de dificultad
class RecipeDifficulty {
  static const String easy = 'Fácil';
  static const String medium = 'Intermedio';
  static const String hard = 'Difícil';
  static const String expert = 'Experto';

  static List<String> get allLevels => [easy, medium, hard, expert];
}

// Tipos de cocina
class CuisineType {
  static const String mexican = 'Mexicana';
  static const String italian = 'Italiana';
  static const String chinese = 'China';
  static const String japanese = 'Japonesa';
  static const String french = 'Francesa';
  static const String indian = 'India';
  static const String mediterranean = 'Mediterránea';
  static const String american = 'Americana';
  static const String thai = 'Tailandesa';
  static const String spanish = 'Española';
  static const String international = 'Internacional';

  static List<String> get allTypes => [
        mexican,
        italian,
        chinese,
        japanese,
        french,
        indian,
        mediterranean,
        american,
        thai,
        spanish,
        international,
      ];
}