class Ingredient {
  final String name;
  final String category;
  final double confidence;
  final String? description;

  const Ingredient({
    required this.name,
    required this.category,
    required this.confidence,
    this.description,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      name: json['name'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'confidence': confidence,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Ingredient(name: $name, category: $category, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ingredient &&
        other.name == name &&
        other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;
}

// Categorías comunes de ingredientes
class IngredientCategory {
  static const String vegetables = 'Vegetales';
  static const String fruits = 'Frutas';
  static const String meat = 'Carnes';
  static const String dairy = 'Lácteos';
  static const String grains = 'Granos y Cereales';
  static const String spices = 'Especias y Condimentos';
  static const String seafood = 'Mariscos';
  static const String legumes = 'Legumbres';
  static const String oils = 'Aceites y Grasas';
  static const String herbs = 'Hierbas';
  static const String nuts = 'Frutos Secos';
  static const String other = 'Otros';

  static List<String> get allCategories => [
        vegetables,
        fruits,
        meat,
        dairy,
        grains,
        spices,
        seafood,
        legumes,
        oils,
        herbs,
        nuts,
        other,
      ];
}