class FoodItem {
  final String id;
  final String name;
  final String? brand;
  final String? barcode;
  final double servingSize; // en grammes
  final String servingUnit; // 'g', 'ml', 'piece', etc.
  
  // Macronutriments pour 100g
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  
  // Micronutriments optionnels
  final double? sodiumPer100g;
  final double? calciumPer100g;
  final double? ironPer100g;
  
  final bool isFavorite;
  final DateTime? lastUsed;
  final int usageCount;
  
  final String category; // 'protein', 'carbs', 'vegetables', 'fruits', 'dairy', 'snacks', etc.

  FoodItem({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    required this.servingSize,
    this.servingUnit = 'g',
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g = 0,
    this.sugarPer100g = 0,
    this.sodiumPer100g,
    this.calciumPer100g,
    this.ironPer100g,
    this.isFavorite = false,
    this.lastUsed,
    this.usageCount = 0,
    required this.category,
  });

  // Calculer les valeurs nutritionnelles pour une quantité donnée
  double getCalories(double quantity) => (caloriesPer100g * quantity) / 100;
  double getProtein(double quantity) => (proteinPer100g * quantity) / 100;
  double getCarbs(double quantity) => (carbsPer100g * quantity) / 100;
  double getFat(double quantity) => (fatPer100g * quantity) / 100;
  double getFiber(double quantity) => (fiberPer100g * quantity) / 100;
  double getSugar(double quantity) => (sugarPer100g * quantity) / 100;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'barcode': barcode,
      'serving_size': servingSize,
      'serving_unit': servingUnit,
      'calories_per_100g': caloriesPer100g,
      'protein_per_100g': proteinPer100g,
      'carbs_per_100g': carbsPer100g,
      'fat_per_100g': fatPer100g,
      'fiber_per_100g': fiberPer100g,
      'sugar_per_100g': sugarPer100g,
      'sodium_per_100g': sodiumPer100g,
      'calcium_per_100g': calciumPer100g,
      'iron_per_100g': ironPer100g,
      'is_favorite': isFavorite ? 1 : 0,
      'last_used': lastUsed?.toIso8601String(),
      'usage_count': usageCount,
      'category': category,
    };
  }

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      barcode: map['barcode'],
      servingSize: map['serving_size'],
      servingUnit: map['serving_unit'] ?? 'g',
      caloriesPer100g: map['calories_per_100g'],
      proteinPer100g: map['protein_per_100g'],
      carbsPer100g: map['carbs_per_100g'],
      fatPer100g: map['fat_per_100g'],
      fiberPer100g: map['fiber_per_100g'] ?? 0,
      sugarPer100g: map['sugar_per_100g'] ?? 0,
      sodiumPer100g: map['sodium_per_100g'],
      calciumPer100g: map['calcium_per_100g'],
      ironPer100g: map['iron_per_100g'],
      isFavorite: map['is_favorite'] == 1,
      lastUsed: map['last_used'] != null ? DateTime.parse(map['last_used']) : null,
      usageCount: map['usage_count'] ?? 0,
      category: map['category'],
    );
  }

  FoodItem copyWith({
    String? name,
    String? brand,
    String? barcode,
    double? servingSize,
    String? servingUnit,
    double? caloriesPer100g,
    double? proteinPer100g,
    double? carbsPer100g,
    double? fatPer100g,
    double? fiberPer100g,
    double? sugarPer100g,
    bool? isFavorite,
    DateTime? lastUsed,
    int? usageCount,
    String? category,
  }) {
    return FoodItem(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      servingSize: servingSize ?? this.servingSize,
      servingUnit: servingUnit ?? this.servingUnit,
      caloriesPer100g: caloriesPer100g ?? this.caloriesPer100g,
      proteinPer100g: proteinPer100g ?? this.proteinPer100g,
      carbsPer100g: carbsPer100g ?? this.carbsPer100g,
      fatPer100g: fatPer100g ?? this.fatPer100g,
      fiberPer100g: fiberPer100g ?? this.fiberPer100g,
      sugarPer100g: sugarPer100g ?? this.sugarPer100g,
      sodiumPer100g: sodiumPer100g,
      calciumPer100g: calciumPer100g,
      ironPer100g: ironPer100g,
      isFavorite: isFavorite ?? this.isFavorite,
      lastUsed: lastUsed ?? this.lastUsed,
      usageCount: usageCount ?? this.usageCount,
      category: category ?? this.category,
    );
  }
}
