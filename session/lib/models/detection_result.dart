import 'ingredient.dart';
import 'kitchen_utensil.dart';

class DetectionResult {
  final List<Ingredient> ingredients;
  final List<KitchenUtensil> utensils;
  final String? additionalText;
  final DateTime detectionTime;
  final double overallConfidence;

  const DetectionResult({
    required this.ingredients,
    required this.utensils,
    this.additionalText,
    required this.detectionTime,
    required this.overallConfidence,
  });

  bool get hasIngredients => ingredients.isNotEmpty;
  bool get hasUtensils => utensils.isNotEmpty;
  bool get hasDetections => hasIngredients || hasUtensils;

  List<String> get ingredientNames => ingredients.map((i) => i.name).toList();
  List<String> get utensilNames => utensils.map((u) => u.name).toList();

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      ingredients: (json['ingredients'] as List)
          .map((ingredient) => Ingredient.fromJson(ingredient as Map<String, dynamic>))
          .toList(),
      utensils: (json['utensils'] as List)
          .map((utensil) => KitchenUtensil.fromJson(utensil as Map<String, dynamic>))
          .toList(),
      additionalText: json['additionalText'] as String?,
      detectionTime: DateTime.parse(json['detectionTime'] as String),
      overallConfidence: (json['overallConfidence'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients.map((i) => i.toJson()).toList(),
      'utensils': utensils.map((u) => u.toJson()).toList(),
      'additionalText': additionalText,
      'detectionTime': detectionTime.toIso8601String(),
      'overallConfidence': overallConfidence,
    };
  }

  DetectionResult copyWith({
    List<Ingredient>? ingredients,
    List<KitchenUtensil>? utensils,
    String? additionalText,
    DateTime? detectionTime,
    double? overallConfidence,
  }) {
    return DetectionResult(
      ingredients: ingredients ?? this.ingredients,
      utensils: utensils ?? this.utensils,
      additionalText: additionalText ?? this.additionalText,
      detectionTime: detectionTime ?? this.detectionTime,
      overallConfidence: overallConfidence ?? this.overallConfidence,
    );
  }

  @override
  String toString() {
    return 'DetectionResult(ingredients: ${ingredients.length}, utensils: ${utensils.length}, confidence: $overallConfidence)';
  }
}