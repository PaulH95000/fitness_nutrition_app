import 'food_item.dart';

class MealEntry {
  final String id;
  final FoodItem foodItem;
  final double quantity; // en grammes
  final DateTime consumedAt;
  final String mealType; // 'breakfast', 'lunch', 'dinner', 'snack'

  MealEntry({
    required this.id,
    required this.foodItem,
    required this.quantity,
    required this.consumedAt,
    required this.mealType,
  });

  double get totalCalories => foodItem.getCalories(quantity);
  double get totalProtein => foodItem.getProtein(quantity);
  double get totalCarbs => foodItem.getCarbs(quantity);
  double get totalFat => foodItem.getFat(quantity);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'food_id': foodItem.id,
      'quantity': quantity,
      'consumed_at': consumedAt.toIso8601String(),
      'meal_type': mealType,
    };
  }
}

class DailyNutrition {
  final DateTime date;
  final List<MealEntry> meals;

  DailyNutrition({
    required this.date,
    required this.meals,
  });

  double get totalCalories => meals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get totalProtein => meals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get totalCarbs => meals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double get totalFat => meals.fold(0, (sum, meal) => sum + meal.totalFat);

  List<MealEntry> getMealsByType(String type) {
    return meals.where((meal) => meal.mealType == type).toList();
  }

  double getCaloriesByMealType(String type) {
    return getMealsByType(type).fold(0, (sum, meal) => sum + meal.totalCalories);
  }
}

class MealPlan {
  final String id;
  final String name;
  final List<PlannedFood> foods;
  final DateTime createdAt;
  final double targetCalories;
  final double targetProtein;

  MealPlan({
    required this.id,
    required this.name,
    required this.foods,
    required this.targetCalories,
    required this.targetProtein,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get totalCalories => foods.fold(0, (sum, food) => sum + food.calories);
  double get totalProtein => foods.fold(0, (sum, food) => sum + food.protein);
  double get totalCarbs => foods.fold(0, (sum, food) => sum + food.carbs);
  double get totalFat => foods.fold(0, (sum, food) => sum + food.fat);

  bool get meetsTargets {
    final caloriesDiff = (totalCalories - targetCalories).abs();
    final proteinDiff = (totalProtein - targetProtein).abs();
    return caloriesDiff <= 50 && proteinDiff <= 10;
  }
}

class PlannedFood {
  final FoodItem foodItem;
  final double quantity;

  PlannedFood({
    required this.foodItem,
    required this.quantity,
  });

  double get calories => foodItem.getCalories(quantity);
  double get protein => foodItem.getProtein(quantity);
  double get carbs => foodItem.getCarbs(quantity);
  double get fat => foodItem.getFat(quantity);
}
