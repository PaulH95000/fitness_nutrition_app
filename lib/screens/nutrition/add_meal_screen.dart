import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../providers/nutrition_provider.dart';
import '../../models/food_item.dart';
import '../../core/theme/app_theme.dart';

class AddMealScreen extends StatefulWidget {
  final DateTime? selectedDate;
  final String? initialMealType;

  const AddMealScreen({
    super.key,
    this.selectedDate,
    this.initialMealType,
  });

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _searchController = TextEditingController();
  late String _selectedMealType;
  bool _showScanner = false;

  @override
  void initState() {
    super.initState();
    _selectedMealType = widget.initialMealType ?? 'breakfast';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un aliment'),
        actions: [
          IconButton(
            icon: Icon(_showScanner ? Icons.search : Icons.qr_code_scanner),
            onPressed: () {
              setState(() {
                _showScanner = !_showScanner;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (!_showScanner) ...[
            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un aliment...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<NutritionProvider>().searchFood('');
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      context.read<NutritionProvider>().searchFood(value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: _selectedMealType,
                    decoration: const InputDecoration(
                      labelText: 'Type de repas',
                      prefixIcon: Icon(Icons.restaurant_menu),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'breakfast', child: Text('Petit-déjeuner')),
                      DropdownMenuItem(value: 'lunch', child: Text('Déjeuner')),
                      DropdownMenuItem(value: 'dinner', child: Text('Dîner')),
                      DropdownMenuItem(value: 'snack', child: Text('Collation')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedMealType = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Résultats de recherche
            Expanded(
              child: Consumer<NutritionProvider>(
                builder: (context, provider, child) {
                  if (_searchController.text.isEmpty) {
                    return _buildQuickAccessLists(provider);
                  }
                  
                  if (provider.isSearching) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  if (provider.searchResults.isEmpty) {
                    return const Center(
                      child: Text('Aucun résultat trouvé'),
                    );
                  }
                  
                  return ListView.builder(
                    itemCount: provider.searchResults.length,
                    itemBuilder: (context, index) {
                      final food = provider.searchResults[index];
                      return _buildFoodTile(context, food);
                    },
                  );
                },
              ),
            ),
          ] else ...[
            // Scanner de code-barres
            Expanded(
              child: MobileScanner(
                onDetect: (capture) async {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty) {
                    final barcode = barcodes.first.rawValue;
                    if (barcode != null) {
                      final food = await context.read<NutritionProvider>().scanBarcode(barcode);
                      if (food != null && mounted) {
                        setState(() {
                          _showScanner = false;
                        });
                        _showAddFoodDialog(context, food);
                      }
                    }
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickAccessLists(NutritionProvider provider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (provider.favoriteFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Favoris',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...provider.favoriteFoods.map((food) => _buildFoodTile(context, food)),
            const Divider(),
          ],
          
          if (provider.recentFoods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Récents',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            ...provider.recentFoods.map((food) => _buildFoodTile(context, food)),
          ],
        ],
      ),
    );
  }

  Widget _buildFoodTile(BuildContext context, FoodItem food) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(
          Icons.restaurant,
          color: AppTheme.primaryColor,
        ),
      ),
      title: Text(food.name),
      subtitle: Text('${food.caloriesPer100g.toInt()} kcal / 100g'),
      trailing: IconButton(
        icon: Icon(
          food.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: food.isFavorite ? Colors.red : null,
        ),
        onPressed: () {
          context.read<NutritionProvider>().toggleFavorite(food);
        },
      ),
      onTap: () {
        _showAddFoodDialog(context, food);
      },
    );
  }

  void _showAddFoodDialog(BuildContext context, FoodItem food) {
    final quantityController = TextEditingController(text: '100');
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(food.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: quantityController,
              decoration: const InputDecoration(
                labelText: 'Quantité (g)',
                suffixText: 'g',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    _buildNutrientRow('Calories', food.getCalories(double.tryParse(quantityController.text) ?? 100).toInt().toString(), 'kcal'),
                    _buildNutrientRow('Protéines', food.getProtein(double.tryParse(quantityController.text) ?? 100).toInt().toString(), 'g'),
                    _buildNutrientRow('Glucides', food.getCarbs(double.tryParse(quantityController.text) ?? 100).toInt().toString(), 'g'),
                    _buildNutrientRow('Lipides', food.getFat(double.tryParse(quantityController.text) ?? 100).toInt().toString(), 'g'),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              final quantity = double.tryParse(quantityController.text);
              if (quantity != null && quantity > 0) {
                await context.read<NutritionProvider>().addMealEntry(
                  foodItem: food,
                  quantity: quantity,
                  mealType: _selectedMealType,
                );
                if (mounted) {
                  Navigator.pop(dialogContext);
                  Navigator.pop(context);
                }
              }
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, String value, String unit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text('$value $unit', style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
