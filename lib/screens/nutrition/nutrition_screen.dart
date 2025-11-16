import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import 'add_meal_screen.dart';
import 'meal_planner_screen.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadTodayMeals();
      context.read<NutritionProvider>().loadFavoriteFoods();
      context.read<NutritionProvider>().loadRecentFoods();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restaurant_menu),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer2<NutritionProvider, UserProvider>(
        builder: (context, nutritionProvider, userProvider, child) {
          if (nutritionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final userProfile = userProvider.userProfile;
          if (userProfile == null) {
            return const Center(
              child: Text('Veuillez configurer votre profil d\'abord'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => nutritionProvider.loadTodayMeals(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte récapitulative des calories
                  _buildCaloriesSummaryCard(
                    context,
                    nutritionProvider,
                    userProfile.dailyCaloriesTarget.toDouble(),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Graphique des macros
                  _buildMacrosCard(
                    context,
                    nutritionProvider,
                    userProfile,
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Liste des repas par type
                  _buildMealTypeSection(context, nutritionProvider, 'breakfast', 'Petit-déjeuner'),
                  const SizedBox(height: 16),
                  _buildMealTypeSection(context, nutritionProvider, 'lunch', 'Déjeuner'),
                  const SizedBox(height: 16),
                  _buildMealTypeSection(context, nutritionProvider, 'dinner', 'Dîner'),
                  const SizedBox(height: 16),
                  _buildMealTypeSection(context, nutritionProvider, 'snack', 'Collations'),
                  
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddMealScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
    );
  }

  Widget _buildCaloriesSummaryCard(BuildContext context, NutritionProvider provider, double target) {
    final consumed = provider.todayCalories;
    final remaining = target - consumed;
    final percentage = (consumed / target).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aujourd\'hui',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE d MMMM', 'fr_FR').format(DateTime.now()),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: remaining >= 0 ? AppTheme.accentColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    remaining >= 0 ? 'Reste ${remaining.toInt()} kcal' : 'Dépassé de ${remaining.abs().toInt()} kcal',
                    style: TextStyle(
                      color: remaining >= 0 ? AppTheme.accentColor : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Barre de progression circulaire
            SizedBox(
              height: 160,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        percentage > 1.0 ? Colors.red : AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        consumed.toInt().toString(),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'sur ${target.toInt()} kcal',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacrosCard(BuildContext context, NutritionProvider provider, userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Macronutriments',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            
            _buildMacroRow(
              'Protéines',
              provider.todayProtein,
              userProfile.proteinTarget.toDouble(),
              AppTheme.proteinColor,
            ),
            const SizedBox(height: 12),
            
            _buildMacroRow(
              'Glucides',
              provider.todayCarbs,
              userProfile.carbsTarget.toDouble(),
              AppTheme.carbsColor,
            ),
            const SizedBox(height: 12),
            
            _buildMacroRow(
              'Lipides',
              provider.todayFat,
              userProfile.fatTarget.toDouble(),
              AppTheme.fatColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroRow(String label, double current, double target, Color color) {
    final percentage = (current / target).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(
              '${current.toInt()}g / ${target.toInt()}g',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSection(BuildContext context, NutritionProvider provider, String mealType, String title) {
    final meals = provider.getMealsByType(mealType);
    final calories = provider.getCaloriesByMealType(mealType);

    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: Text(
              '${calories.toInt()} kcal',
              style: TextStyle(
                color: AppTheme.caloriesColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Aucun aliment ajouté',
                style: TextStyle(color: Colors.grey[600]),
              ),
            )
          else
            ...meals.map((meal) => ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: Icon(
                  Icons.restaurant,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(meal.foodItem.name),
              subtitle: Text('${meal.quantity.toInt()}g'),
              trailing: Text(
                '${meal.totalCalories.toInt()} kcal',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onLongPress: () {
                _showDeleteDialog(context, meal.id);
              },
            )),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String mealId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous supprimer cet aliment ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              context.read<NutritionProvider>().deleteMealEntry(mealId);
              Navigator.pop(context);
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
