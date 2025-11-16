import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/food_item.dart';
import 'package:uuid/uuid.dart';

class FoodApiService {
  static const String _baseUrl = 'https://world.openfoodfacts.org/api/v2';
  final _uuid = const Uuid();

  // Rechercher des aliments par nom
  Future<List<FoodItem>> searchFood(String query) async {
    try {
      final url = Uri.parse('$_baseUrl/search?search_terms=$query&page_size=20&json=true');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final products = data['products'] as List;
        
        return products.map((product) => _parseFoodItem(product)).where((item) => item != null).cast<FoodItem>().toList();
      }
      return [];
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  // Récupérer un aliment par code-barres
  Future<FoodItem?> getFoodByBarcode(String barcode) async {
    try {
      final url = Uri.parse('$_baseUrl/product/$barcode.json');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 1) {
          return _parseFoodItem(data['product']);
        }
      }
      return null;
    } catch (e) {
      print('Erreur lors de la récupération du produit: $e');
      return null;
    }
  }

  FoodItem? _parseFoodItem(Map<String, dynamic> product) {
    try {
      final nutriments = product['nutriments'] ?? {};
      
      // Extraire les valeurs nutritionnelles pour 100g
      final calories = _parseDouble(nutriments['energy-kcal_100g']) ?? 
                      (_parseDouble(nutriments['energy_100g']) ?? 0) / 4.184;
      final protein = _parseDouble(nutriments['proteins_100g']) ?? 0;
      final carbs = _parseDouble(nutriments['carbohydrates_100g']) ?? 0;
      final fat = _parseDouble(nutriments['fat_100g']) ?? 0;
      final fiber = _parseDouble(nutriments['fiber_100g']) ?? 0;
      final sugar = _parseDouble(nutriments['sugars_100g']) ?? 0;
      final sodium = _parseDouble(nutriments['sodium_100g']);

      // Déterminer la catégorie
      String category = _determineCategory(product);

      return FoodItem(
        id: _uuid.v4(),
        name: product['product_name'] ?? 'Produit sans nom',
        brand: product['brands'],
        barcode: product['code'],
        servingSize: _parseDouble(product['serving_quantity']) ?? 100,
        servingUnit: product['serving_quantity_unit'] ?? 'g',
        caloriesPer100g: calories,
        proteinPer100g: protein,
        carbsPer100g: carbs,
        fatPer100g: fat,
        fiberPer100g: fiber,
        sugarPer100g: sugar,
        sodiumPer100g: sodium,
        category: category,
      );
    } catch (e) {
      print('Erreur lors du parsing du produit: $e');
      return null;
    }
  }

  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String _determineCategory(Map<String, dynamic> product) {
    final categories = (product['categories_tags'] as List?)?.cast<String>() ?? [];
    
    // Logique simple de catégorisation
    if (categories.any((c) => c.contains('meat') || c.contains('poultry') || c.contains('fish'))) {
      return 'protein';
    } else if (categories.any((c) => c.contains('dairy') || c.contains('cheese') || c.contains('yogurt'))) {
      return 'dairy';
    } else if (categories.any((c) => c.contains('fruit'))) {
      return 'fruits';
    } else if (categories.any((c) => c.contains('vegetable'))) {
      return 'vegetables';
    } else if (categories.any((c) => c.contains('bread') || c.contains('pasta') || c.contains('rice') || c.contains('cereal'))) {
      return 'carbs';
    } else if (categories.any((c) => c.contains('snack') || c.contains('dessert') || c.contains('candy'))) {
      return 'snacks';
    }
    
    return 'other';
  }
}
