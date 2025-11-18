import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/meal_entry.dart';
import '../services/database_service.dart';
import '../services/food_api_service.dart';
import '../data/default_foods.dart';
import 'package:uuid/uuid.dart';

class NutritionProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  final _foodApiService = FoodApiService();
  
  List<MealEntry> _todayMeals = [];
  List<FoodItem> _favoriteFoods = [];
  List<FoodItem> _recentFoods = [];
  List<FoodItem> _searchResults = [];
  
  bool _isLoading = false;
  bool _isSearching = false;

  List<MealEntry> get todayMeals => _todayMeals;
  List<FoodItem> get favoriteFoods => _favoriteFoods;
  List<FoodItem> get recentFoods => _recentFoods;
  List<FoodItem> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  bool get isSearching => _isSearching;

  // Statistiques du jour
  double get todayCalories => _todayMeals.fold(0, (sum, meal) => sum + meal.totalCalories);
  double get todayProtein => _todayMeals.fold(0, (sum, meal) => sum + meal.totalProtein);
  double get todayCarbs => _todayMeals.fold(0, (sum, meal) => sum + meal.totalCarbs);
  double get todayFat => _todayMeals.fold(0, (sum, meal) => sum + meal.totalFat);

  Future<void> initializeDefaultFoods() async {
    try {
      final allFoods = await DatabaseService.instance.getAllFoodItems();
      if (allFoods.isEmpty) {
        // Ajouter les aliments par défaut
        final defaultFoods = DefaultFoods.getDefaultFrenchFoods();
        for (final food in defaultFoods) {
          await DatabaseService.instance.insertFoodItem(food);
        }
        print('${defaultFoods.length} aliments par défaut ajoutés');
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation des aliments: $e');
    }
  }

  Future<void> loadTodayMeals() async {
    await loadMealsForDate(DateTime.now());
  }

  Future<void> loadMealsForDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _todayMeals = await DatabaseService.instance.getMealEntriesForDate(date);
    } catch (e) {
      print('Erreur lors du chargement des repas: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadWeeklyData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implémenter le chargement des données hebdomadaires
      // Pour l'instant, juste simuler le chargement
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Erreur lors du chargement des données hebdomadaires: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadFavoriteFoods() async {
    try {
      _favoriteFoods = await DatabaseService.instance.getFavoriteFoods();
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des favoris: $e');
    }
  }

  Future<void> loadRecentFoods() async {
    try {
      _recentFoods = await DatabaseService.instance.getRecentFoods(limit: 20);
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des aliments récents: $e');
    }
  }

  Future<void> searchFood(String query) async {
    final trimmedQuery = query.trim();
    print('🔍 searchFood called with query: "$trimmedQuery"');

    if (trimmedQuery.isEmpty) {
      print('🔍 Query empty, clearing results');
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      // Chercher d'abord dans la base locale
      final localResults = await DatabaseService.instance.searchFoodItems(trimmedQuery);
      print('🔍 Recherche locale "$trimmedQuery": ${localResults.length} résultats trouvés');

      // Debug: afficher les noms des premiers résultats
      if (localResults.isNotEmpty) {
        print('🔍 Premiers résultats: ${localResults.take(3).map((f) => f.name).join(", ")}');
      }

      // Si on a assez de résultats locaux, ne pas chercher dans l'API
      if (localResults.length >= 5) {
        _searchResults = localResults;
        print('🔍 Assez de résultats locaux (${localResults.length}), pas de recherche API');
      } else {
        // Sinon, chercher dans l'API OpenFoodFacts et limiter les résultats
        try {
          print('🔍 Lancement recherche API...');
          final apiResults = await _foodApiService.searchFood(trimmedQuery);
          print('🔍 Recherche API: ${apiResults.length} résultats');
          // Limiter les résultats API à 10 et combiner avec les résultats locaux
          _searchResults = [...localResults, ...apiResults.take(10)];
        } catch (e) {
          print('⚠️ Erreur API, utilisation résultats locaux uniquement: $e');
          _searchResults = localResults;
        }
      }

      print('🔍 Total résultats finaux: ${_searchResults.length}');
    } catch (e) {
      print('❌ Erreur lors de la recherche: $e');
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  Future<FoodItem?> scanBarcode(String barcode) async {
    try {
      // Chercher d'abord dans la base locale
      final localFoods = await DatabaseService.instance.getAllFoodItems();
      final localFood = localFoods.where((f) => f.barcode == barcode).firstOrNull;
      
      if (localFood != null) return localFood;
      
      // Sinon, chercher dans l'API
      final apiFood = await _foodApiService.getFoodByBarcode(barcode);
      
      if (apiFood != null) {
        // Sauvegarder dans la base locale
        await DatabaseService.instance.insertFoodItem(apiFood);
      }
      
      return apiFood;
    } catch (e) {
      print('Erreur lors du scan: $e');
      return null;
    }
  }

  Future<void> addMealEntry({
    required FoodItem foodItem,
    required double quantity,
    required String mealType,
  }) async {
    try {
      final entry = MealEntry(
        id: _uuid.v4(),
        foodItem: foodItem,
        quantity: quantity,
        consumedAt: DateTime.now(),
        mealType: mealType,
      );

      await DatabaseService.instance.insertMealEntry(entry);
      
      // Mettre à jour l'aliment (dernière utilisation et compteur)
      final updatedFood = foodItem.copyWith(
        lastUsed: DateTime.now(),
        usageCount: foodItem.usageCount + 1,
      );
      await DatabaseService.instance.updateFoodItem(updatedFood);

      // Recharger les repas du jour
      await loadTodayMeals();
    } catch (e) {
      print('Erreur lors de l\'ajout du repas: $e');
    }
  }

  Future<void> updateMealEntry(MealEntry entry) async {
    try {
      await DatabaseService.instance.updateMealEntry(entry);
      await loadTodayMeals();
    } catch (e) {
      print('Erreur lors de la modification: $e');
    }
  }

  Future<void> deleteMealEntry(String entryId) async {
    try {
      await DatabaseService.instance.deleteMealEntry(entryId);
      await loadTodayMeals();
    } catch (e) {
      print('Erreur lors de la suppression: $e');
    }
  }

  Future<void> toggleFavorite(FoodItem food) async {
    try {
      final updatedFood = food.copyWith(isFavorite: !food.isFavorite);
      await DatabaseService.instance.updateFoodItem(updatedFood);
      await loadFavoriteFoods();
      notifyListeners();
    } catch (e) {
      print('Erreur lors de la mise à jour du favori: $e');
    }
  }

  Future<void> addCustomFood(FoodItem food) async {
    try {
      await DatabaseService.instance.insertFoodItem(food);
      notifyListeners();
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'aliment: $e');
    }
  }

  // Générer un plan de repas basé sur les objectifs
  Future<MealPlan> generateMealPlan({
    required double targetCalories,
    required double targetProtein,
    required List<FoodItem> selectedFoods,
  }) async {
    // Algorithme simple de génération de repas
    // Pour une version plus sophistiquée, utiliser un algorithme d'optimisation
    
    final List<PlannedFood> plannedFoods = [];
    double currentCalories = 0;
    double currentProtein = 0;
    
    // Trier les aliments sélectionnés par densité protéique
    selectedFoods.sort((a, b) => 
      (b.proteinPer100g / b.caloriesPer100g).compareTo(a.proteinPer100g / a.caloriesPer100g)
    );
    
    // Ajouter les aliments un par un jusqu'à atteindre les objectifs
    for (var food in selectedFoods) {
      if (currentCalories >= targetCalories) break;
      
      // Calculer la quantité optimale pour cet aliment
      final remainingCalories = targetCalories - currentCalories;
      final remainingProtein = targetProtein - currentProtein;
      
      // Quantité basée sur les calories restantes
      double quantity = (remainingCalories / food.caloriesPer100g) * 100;
      quantity = quantity.clamp(50, 300); // Entre 50g et 300g
      
      plannedFoods.add(PlannedFood(
        foodItem: food,
        quantity: quantity,
      ));
      
      currentCalories += food.getCalories(quantity);
      currentProtein += food.getProtein(quantity);
    }
    
    return MealPlan(
      id: _uuid.v4(),
      name: 'Plan généré - ${DateTime.now().toString().split(' ')[0]}',
      foods: plannedFoods,
      targetCalories: targetCalories,
      targetProtein: targetProtein,
    );
  }

  List<MealEntry> getMealsByType(String mealType) {
    return _todayMeals.where((meal) => meal.mealType == mealType).toList();
  }

  double getCaloriesByMealType(String mealType) {
    return getMealsByType(mealType).fold(0, (sum, meal) => sum + meal.totalCalories);
  }
}
