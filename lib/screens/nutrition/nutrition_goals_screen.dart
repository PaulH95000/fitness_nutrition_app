import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_profile.dart';
import '../../core/theme/app_theme.dart';

/// Écran de configuration des objectifs nutritionnels
/// Design moderne et intuitif
class NutritionGoalsScreen extends StatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProfile = context.read<UserProvider>().userProfile;

    _caloriesController = TextEditingController(
      text: userProfile?.dailyCaloriesTarget.toString() ?? '2000'
    );
    _proteinController = TextEditingController(
      text: userProfile?.proteinTarget.toString() ?? '150'
    );
    _carbsController = TextEditingController(
      text: userProfile?.carbsTarget.toString() ?? '200'
    );
    _fatController = TextEditingController(
      text: userProfile?.fatTarget.toString() ?? '60'
    );
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  Future<void> _saveGoals() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();
      final currentProfile = userProvider.userProfile;

      if (currentProfile == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez d\'abord créer votre profil')),
        );
        return;
      }

      final updatedProfile = UserProfile(
        id: currentProfile.id,
        name: currentProfile.name,
        age: currentProfile.age,
        currentWeight: currentProfile.currentWeight,
        targetWeight: currentProfile.targetWeight,
        height: currentProfile.height,
        gender: currentProfile.gender,
        activityLevel: currentProfile.activityLevel,
        goal: currentProfile.goal,
        dailyCaloriesTarget: int.parse(_caloriesController.text),
        proteinTarget: int.parse(_proteinController.text),
        carbsTarget: int.parse(_carbsController.text),
        fatTarget: int.parse(_fatController.text),
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
      );

      await userProvider.updateUserProfile(updatedProfile);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Objectifs mis à jour avec succès !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Objectifs Nutritionnels',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.secondaryColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppTheme.primaryColor),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Définissez vos objectifs caloriques et macronutriments quotidiens',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Calories card
            _buildGoalCard(
              title: 'Calories',
              icon: Icons.local_fire_department,
              color: Colors.orange,
              controller: _caloriesController,
              unit: 'kcal',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final cal = int.tryParse(value);
                if (cal == null || cal < 1000 || cal > 5000) {
                  return '1000-5000';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            Text(
              'Macronutriments',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Protein card
            _buildGoalCard(
              title: 'Protéines',
              icon: Icons.egg,
              color: Colors.red,
              controller: _proteinController,
              unit: 'g',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final protein = int.tryParse(value);
                if (protein == null || protein < 50 || protein > 400) {
                  return '50-400g';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Carbs card
            _buildGoalCard(
              title: 'Glucides',
              icon: Icons.bakery_dining,
              color: Colors.amber,
              controller: _carbsController,
              unit: 'g',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final carbs = int.tryParse(value);
                if (carbs == null || carbs < 50 || carbs > 500) {
                  return '50-500g';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Fat card
            _buildGoalCard(
              title: 'Lipides',
              icon: Icons.water_drop,
              color: Colors.blue,
              controller: _fatController,
              unit: 'g',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                final fat = int.tryParse(value);
                if (fat == null || fat < 30 || fat > 200) {
                  return '30-200g';
                }
                return null;
              },
            ),

            const SizedBox(height: 32),

            // Save button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Enregistrer',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String title,
    required IconData icon,
    required Color color,
    required TextEditingController controller,
    required String unit,
    String? Function(String?)? validator,
  }) {
    return Container(
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        trailing: SizedBox(
          width: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  validator: validator,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
