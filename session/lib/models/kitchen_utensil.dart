class KitchenUtensil {
  final String name;
  final String category;
  final double confidence;
  final String? description;
  final bool isEssential;

  const KitchenUtensil({
    required this.name,
    required this.category,
    required this.confidence,
    this.description,
    this.isEssential = false,
  });

  factory KitchenUtensil.fromJson(Map<String, dynamic> json) {
    return KitchenUtensil(
      name: json['name'] as String,
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      description: json['description'] as String?,
      isEssential: json['isEssential'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'confidence': confidence,
      'description': description,
      'isEssential': isEssential,
    };
  }

  @override
  String toString() {
    return 'KitchenUtensil(name: $name, category: $category, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is KitchenUtensil &&
        other.name == name &&
        other.category == category;
  }

  @override
  int get hashCode => name.hashCode ^ category.hashCode;
}

// Categorías de utensilios de cocina
class UtensilCategory {
  static const String cookware = 'Utensilios de Cocción';
  static const String cutlery = 'Cuchillería';
  static const String measuring = 'Medición';
  static const String preparation = 'Preparación';
  static const String baking = 'Horneado';
  static const String serving = 'Servir';
  static const String storage = 'Almacenamiento';
  static const String appliances = 'Electrodomésticos';
  static const String other = 'Otros';

  static List<String> get allCategories => [
        cookware,
        cutlery,
        measuring,
        preparation,
        baking,
        serving,
        storage,
        appliances,
        other,
      ];
}