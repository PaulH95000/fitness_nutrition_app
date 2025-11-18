import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/theme/app_theme.dart';
import 'add_meal_screen.dart';
import 'meal_planner_screen.dart';
import 'weekly_report_screen.dart';
import 'nutrition_goals_screen.dart';

/// Interface Nutrition inspirée de MyFitnessPal
/// Design moderne, clair et intuitif
class NutritionScreenV2 extends StatefulWidget {
  const NutritionScreenV2({super.key});

  @override
  State<NutritionScreenV2> createState() => _NutritionScreenV2State();
}

class _NutritionScreenV2State extends State<NutritionScreenV2> {
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadDataForDate(_selectedDate);
  }

  void _loadDataForDate(DateTime date) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NutritionProvider>().loadMealsForDate(date);
      context.read<NutritionProvider>().loadFavoriteFoods();
      context.read<NutritionProvider>().loadRecentFoods();
    });
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      _loadDataForDate(_selectedDate);
    });
  }

  bool get _isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Nutrition',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.restaurant_menu, color: AppTheme.primaryColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MealPlannerScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppTheme.primaryColor),
            tooltip: 'Objectifs',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionGoalsScreen()),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('Veuillez configurer votre profil'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to profile
                    },
                    child: const Text('Configurer mon profil'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => nutritionProvider.loadMealsForDate(_selectedDate),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Date selector
                  _buildDateSelector(),

                  // Calories summary (MyFitnessPal style)
                  _buildCaloriesSummaryCard(
                    context,
                    nutritionProvider,
                    userProfile.dailyCaloriesTarget.toDouble(),
                  ),

                  // Macros circular chart (MyFitnessPal style)
                  _buildMacrosCircularChart(
                    context,
                    nutritionProvider,
                    userProfile,
                  ),

                  const SizedBox(height: 8),

                  // Meals timeline
                  _buildMealsTimeline(context, nutritionProvider),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddMealScreen(selectedDate: _selectedDate),
            ),
          ).then((_) => _loadDataForDate(_selectedDate));
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: Colors.black87,
            ),
            onPressed: () => _changeDate(-1),
          ),
          const SizedBox(width: 16),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                  _loadDataForDate(_selectedDate);
                });
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isToday ? AppTheme.primaryColor : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _isToday
                    ? 'Aujourd\'hui'
                    : DateFormat('EEE d MMM', 'fr_FR').format(_selectedDate),
                style: TextStyle(
                  color: _isToday ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.black87,
            ),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  Widget _buildCaloriesSummaryCard(
    BuildContext context,
    NutritionProvider provider,
    double target,
  ) {
    final consumed = provider.todayCalories;
    final remaining = target - consumed;
    final percentage = (consumed / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieInfo('Objectif', target.toInt(), Colors.white70),
              Container(
                height: 50,
                width: 2,
                color: Colors.white24,
              ),
              _buildCalorieInfo('Consommé', consumed.toInt(), Colors.white),
              Container(
                height: 50,
                width: 2,
                color: Colors.white24,
              ),
              _buildCalorieInfo(
                'Restant',
                remaining.toInt(),
                remaining >= 0 ? Colors.greenAccent : Colors.redAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 12,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 1.0 ? Colors.redAccent : Colors.greenAccent,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toInt()}% de l\'objectif',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieInfo(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMacrosCircularChart(
    BuildContext context,
    NutritionProvider provider,
    userProfile,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Macronutriments',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSimpleMacroRow(
            'Protéines',
            provider.todayProtein,
            userProfile.proteinTarget.toDouble(),
            AppTheme.proteinColor,
          ),
          const SizedBox(height: 16),
          _buildSimpleMacroRow(
            'Glucides',
            provider.todayCarbs,
            userProfile.carbsTarget.toDouble(),
            AppTheme.carbsColor,
          ),
          const SizedBox(height: 16),
          _buildSimpleMacroRow(
            'Lipides',
            provider.todayFat,
            userProfile.fatTarget.toDouble(),
            AppTheme.fatColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleMacroRow(String label, double current, double target, Color color) {
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ],
            ),
            Text(
              '${current.toInt()}g / ${target.toInt()}g',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: percentage > 1.0 ? Colors.red : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 10,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildMealsTimeline(BuildContext context, NutritionProvider provider) {
    final mealTypes = [
      {'type': 'breakfast', 'name': 'Petit-déjeuner', 'icon': Icons.wb_sunny_outlined},
      {'type': 'lunch', 'name': 'Déjeuner', 'icon': Icons.lunch_dining_outlined},
      {'type': 'dinner', 'name': 'Dîner', 'icon': Icons.dinner_dining_outlined},
      {'type': 'snack', 'name': 'Collations', 'icon': Icons.cookie_outlined},
    ];

    return Column(
      children: mealTypes.map((mealType) {
        return _buildMealCard(
          context,
          provider,
          mealType['type'] as String,
          mealType['name'] as String,
          mealType['icon'] as IconData,
        );
      }).toList(),
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    NutritionProvider provider,
    String mealType,
    String title,
    IconData icon,
  ) {
    final meals = provider.getMealsByType(mealType);
    final calories = provider.getCaloriesByMealType(mealType);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${calories.toInt()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Text(
                  'kcal',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddMealScreen(
                    selectedDate: _selectedDate,
                    initialMealType: mealType,
                  ),
                ),
              ).then((_) => _loadDataForDate(_selectedDate));
            },
          ),
          if (meals.isNotEmpty)
            ...meals.map((meal) => Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey[200]!),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.restaurant, size: 20),
                    ),
                    title: Text(
                      meal.foodItem.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    subtitle: Text(
                      '${meal.quantity.toInt()}g • ${meal.foodItem.brand ?? ""}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${meal.totalCalories.toInt()} kcal',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'P${meal.totalProtein.toInt()} G${meal.totalCarbs.toInt()} L${meal.totalFat.toInt()}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton(
                          icon: const Icon(Icons.more_vert, size: 20),
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit, color: AppTheme.primaryColor, size: 20),
                                  SizedBox(width: 8),
                                  Text('Modifier'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete, color: Colors.red, size: 20),
                                  SizedBox(width: 8),
                                  Text('Supprimer'),
                                ],
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              _showEditMealDialog(context, provider, meal);
                            } else if (value == 'delete') {
                              provider.deleteMealEntry(meal.id);
                              _loadDataForDate(_selectedDate);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ))
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Appuyez pour ajouter un aliment',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ),
        ],
      ),
    );
  }

  void _showEditMealDialog(BuildContext context, NutritionProvider provider, meal) {
    final quantityController = TextEditingController(text: meal.quantity.toInt().toString());

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Modifier la quantité'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meal.foodItem.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Quantité (${meal.foodItem.servingUnit})',
                hintText: 'Ex: 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: meal.foodItem.servingUnit,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu nutritionnel:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildNutrientPreview(
                    quantityController,
                    meal.foodItem,
                  ),
                ],
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
              final newQuantity = double.tryParse(quantityController.text);
              if (newQuantity == null || newQuantity <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Quantité invalide')),
                );
                return;
              }

              // Update meal entry
              final updatedMeal = meal.copyWith(quantity: newQuantity);
              await provider.updateMealEntry(updatedMeal);

              Navigator.pop(dialogContext);
              _loadDataForDate(_selectedDate);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Repas modifié avec succès'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientPreview(TextEditingController controller, foodItem) {
    return StreamBuilder(
      stream: Stream.periodic(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        final quantity = double.tryParse(controller.text) ?? 0;
        final calories = foodItem.getCalories(quantity);
        final protein = foodItem.getProtein(quantity);
        final carbs = foodItem.getCarbs(quantity);
        final fat = foodItem.getFat(quantity);

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${calories.toInt()} kcal',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            Text(
              'P: ${protein.toInt()}g',
              style: TextStyle(color: AppTheme.proteinColor, fontSize: 12),
            ),
            Text(
              'G: ${carbs.toInt()}g',
              style: TextStyle(color: AppTheme.carbsColor, fontSize: 12),
            ),
            Text(
              'L: ${fat.toInt()}g',
              style: TextStyle(color: AppTheme.fatColor, fontSize: 12),
            ),
          ],
        );
      },
    );
  }
}
