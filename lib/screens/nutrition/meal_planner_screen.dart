import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/food_item.dart';
import '../../models/meal_entry.dart';
import '../../core/theme/app_theme.dart';

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  List<FoodItem> _selectedFoods = [];
  MealPlan? _generatedPlan;
  bool _isGenerating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadFavoriteFoods();
      context.read<NutritionProvider>().loadRecentFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificateur de repas'),
      ),
      body: Consumer2<NutritionProvider, UserProvider>(
        builder: (context, nutritionProvider, userProvider, child) {
          final userProfile = userProvider.userProfile;
          if (userProfile == null) {
            return const Center(
              child: Text('Veuillez configurer votre profil d\'abord'),
            );
          }

          final remainingCalories = userProfile.dailyCaloriesTarget - nutritionProvider.todayCalories;
          final remainingProtein = userProfile.proteinTarget - nutritionProvider.todayProtein;

          return Column(
            children: [
              // Objectifs restants
              Card(
                margin: const EdgeInsets.all(16),
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Objectifs restants pour aujourd\'hui',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildTargetChip(
                            'Calories',
                            '${remainingCalories.toInt()} kcal',
                            AppTheme.caloriesColor,
                          ),
                          _buildTargetChip(
                            'Protéines',
                            '${remainingProtein.toInt()}g',
                            AppTheme.proteinColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Section de sélection des aliments
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Sélectionner les aliments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: _showFoodSelectionDialog,
                      child: const Text('Ajouter'),
                    ),
                  ],
                ),
              ),

              // Aliments sélectionnés
              if (_selectedFoods.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    'Aucun aliment sélectionné.\nAjoutez vos aliments favoris ou récents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _selectedFoods.length,
                    itemBuilder: (context, index) {
                      final food = _selectedFoods[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.restaurant),
                          title: Text(food.name),
                          subtitle: Text('${food.caloriesPer100g.toInt()} kcal/100g'),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () {
                              setState(() {
                                _selectedFoods.removeAt(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // Plan généré
              if (_generatedPlan != null) ...[
                const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Plan généré',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _generateMealPlan,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Résumé nutritionnel
                        Card(
                          color: _generatedPlan!.meetsTargets
                              ? AppTheme.accentColor.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildPlanStat(
                                      'Calories',
                                      '${_generatedPlan!.totalCalories.toInt()}',
                                      'Cible: ${remainingCalories.toInt()}',
                                    ),
                                    _buildPlanStat(
                                      'Protéines',
                                      '${_generatedPlan!.totalProtein.toInt()}g',
                                      'Cible: ${remainingProtein.toInt()}g',
                                    ),
                                  ],
                                ),
                                if (_generatedPlan!.meetsTargets)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle, color: AppTheme.accentColor, size: 20),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Objectifs atteints !',
                                          style: TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Liste des aliments du plan
                        ..._generatedPlan!.foods.map((plannedFood) => Card(
                          child: ListTile(
                            leading: const Icon(Icons.check_circle_outline, color: AppTheme.accentColor),
                            title: Text(plannedFood.foodItem.name),
                            subtitle: Text('${plannedFood.quantity.toInt()}g'),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${plannedFood.calories.toInt()} kcal',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '${plannedFood.protein.toInt()}g prot.',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_generatedPlan != null)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _generatedPlan = null;
                            });
                          },
                          child: const Text('Annuler'),
                        ),
                      ),
                    if (_generatedPlan != null) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _selectedFoods.isEmpty || _isGenerating
                            ? null
                            : (_generatedPlan == null ? _generateMealPlan : _saveMealPlan),
                        child: _isGenerating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(_generatedPlan == null ? 'Générer' : 'Enregistrer'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTargetChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlanStat(String label, String value, String target) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(target, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  void _showFoodSelectionDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Consumer<NutritionProvider>(
            builder: (context, provider, child) {
              final allFoods = [...provider.favoriteFoods, ...provider.recentFoods];
              
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Choisir des aliments',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: allFoods.length,
                      itemBuilder: (context, index) {
                        final food = allFoods[index];
                        final isSelected = _selectedFoods.contains(food);
                        
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedFoods.add(food);
                              } else {
                                _selectedFoods.remove(food);
                              }
                            });
                            Navigator.pop(context);
                          },
                          title: Text(food.name),
                          subtitle: Text('${food.caloriesPer100g.toInt()} kcal/100g'),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _generateMealPlan() async {
    if (_selectedFoods.isEmpty) return;

    setState(() {
      _isGenerating = true;
    });

    final userProvider = context.read<UserProvider>();
    final nutritionProvider = context.read<NutritionProvider>();
    
    final remainingCalories = userProvider.userProfile!.dailyCaloriesTarget - nutritionProvider.todayCalories;
    final remainingProtein = userProvider.userProfile!.proteinTarget - nutritionProvider.todayProtein;

    final plan = await nutritionProvider.generateMealPlan(
      targetCalories: remainingCalories,
      targetProtein: remainingProtein,
      selectedFoods: _selectedFoods,
    );

    setState(() {
      _generatedPlan = plan;
      _isGenerating = false;
    });
  }

  Future<void> _saveMealPlan() async {
    if (_generatedPlan == null) return;

    // Enregistrer chaque aliment du plan
    final nutritionProvider = context.read<NutritionProvider>();
    
    for (var plannedFood in _generatedPlan!.foods) {
      await nutritionProvider.addMealEntry(
        foodItem: plannedFood.foodItem,
        quantity: plannedFood.quantity,
        mealType: 'lunch', // Par défaut, ou permettre à l'utilisateur de choisir
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plan de repas enregistré !')),
      );
      Navigator.pop(context);
    }
  }
}
