import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../utils/fitness_calculators.dart';
import '../../core/theme/app_theme.dart';

/// Écran de calculateurs fitness et nutrition
class CalculatorsScreen extends StatefulWidget {
  const CalculatorsScreen({super.key});

  @override
  State<CalculatorsScreen> createState() => _CalculatorsScreenState();
}

class _CalculatorsScreenState extends State<CalculatorsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Controllers pour Body Fat
  final _neckController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipsController = TextEditingController();

  double? _calculatedBMR;
  double? _calculatedTDEE;
  double? _calculatedBodyFat;
  double? _calculatedBMI;
  Map<String, int>? _calculatedMacros;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _neckController.dispose();
    _waistController.dispose();
    _hipsController.dispose();
    super.dispose();
  }

  void _calculateAll() {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.userProfile;

    if (profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez d\'abord créer votre profil')),
      );
      return;
    }

    setState(() {
      // BMR
      _calculatedBMR = FitnessCalculators.calculateBMR(
        weight: profile.currentWeight,
        height: profile.height,
        age: profile.age,
        gender: profile.gender,
      );

      // TDEE
      _calculatedTDEE = FitnessCalculators.calculateTDEE(
        bmr: _calculatedBMR!,
        activityLevel: profile.activityLevel,
      );

      // BMI
      _calculatedBMI = FitnessCalculators.calculateBMI(
        weight: profile.currentWeight,
        height: profile.height,
      );

      // Macros
      final targetCals = FitnessCalculators.calculateTargetCalories(
        tdee: _calculatedTDEE!,
        goal: profile.goal,
      );

      _calculatedMacros = FitnessCalculators.calculateMacros(
        targetCalories: targetCals,
        weight: profile.currentWeight,
        goal: profile.goal,
      );
    });
  }

  void _calculateBodyFat() {
    final userProvider = context.read<UserProvider>();
    final profile = userProvider.userProfile;

    if (profile == null) return;

    final neck = double.tryParse(_neckController.text);
    final waist = double.tryParse(_waistController.text);
    final hips = double.tryParse(_hipsController.text);

    if (neck == null || waist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tour de cou et taille')),
      );
      return;
    }

    if (profile.gender.toLowerCase() == 'female' && hips == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tour de hanches')),
      );
      return;
    }

    setState(() {
      _calculatedBodyFat = FitnessCalculators.calculateBodyFatNavy(
        height: profile.height,
        neck: neck,
        waist: waist,
        hips: hips,
        gender: profile.gender,
      );
    });
  }

  Future<void> _applyCalculatedMacros() async {
    if (_calculatedMacros == null) return;

    final userProvider = context.read<UserProvider>();
    final targetCals = FitnessCalculators.calculateCaloriesFromMacros(
      protein: _calculatedMacros!['protein']!,
      carbs: _calculatedMacros!['carbs']!,
      fat: _calculatedMacros!['fat']!,
    );

    await userProvider.updateUserProfile(
      dailyCaloriesTarget: targetCals,
      proteinTarget: _calculatedMacros!['protein']!,
      carbsTarget: _calculatedMacros!['carbs']!,
      fatTarget: _calculatedMacros!['fat']!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Objectifs nutritionnels mis à jour !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
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
          'Calculateurs',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(text: 'Métabolisme & Macros'),
            Tab(text: 'Body Fat'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMetabolismTab(),
          _buildBodyFatTab(),
        ],
      ),
    );
  }

  Widget _buildMetabolismTab() {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade50,
                  Colors.purple.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.calculate, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Calculez automatiquement vos besoins caloriques et macros selon votre profil',
                    style: TextStyle(color: Colors.black87, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: profile != null ? _calculateAll : null,
              icon: const Icon(Icons.science),
              label: const Text(
                'Calculer',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Results
          if (_calculatedBMR != null) ...[
            _buildResultCard(
              title: 'BMR (Métabolisme de base)',
              value: '${_calculatedBMR!.toInt()} kcal/jour',
              subtitle: 'Calories brûlées au repos',
              icon: Icons.local_fire_department,
              color: Colors.orange,
            ),
            const SizedBox(height: 12),

            _buildResultCard(
              title: 'TDEE (Dépense totale)',
              value: '${_calculatedTDEE!.toInt()} kcal/jour',
              subtitle: 'Avec votre niveau d\'activité',
              icon: Icons.fitness_center,
              color: Colors.green,
            ),
            const SizedBox(height: 12),

            _buildResultCard(
              title: 'IMC (BMI)',
              value: _calculatedBMI!.toStringAsFixed(1),
              subtitle: FitnessCalculators.interpretBMI(_calculatedBMI!),
              icon: Icons.monitor_weight,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),

            // Macros card
            if (_calculatedMacros != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.restaurant, color: AppTheme.primaryColor),
                        SizedBox(width: 12),
                        Text(
                          'Macronutriments recommandés',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildMacroRow('Protéines', _calculatedMacros!['protein']!, Colors.red),
                    const SizedBox(height: 12),
                    _buildMacroRow('Glucides', _calculatedMacros!['carbs']!, Colors.amber),
                    const SizedBox(height: 12),
                    _buildMacroRow('Lipides', _calculatedMacros!['fat']!, Colors.blue),

                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '${FitnessCalculators.calculateCaloriesFromMacros(protein: _calculatedMacros!['protein']!, carbs: _calculatedMacros!['carbs']!, fat: _calculatedMacros!['fat']!)} kcal',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Apply button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _applyCalculatedMacros,
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Appliquer ces objectifs'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildBodyFatTab() {
    final userProvider = context.watch<UserProvider>();
    final profile = userProvider.userProfile;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange.shade50,
                  Colors.red.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.straighten, color: Colors.orange),
                    SizedBox(width: 12),
                    Text(
                      'Méthode US Navy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Mesurez avec un mètre ruban au niveau le plus large. Restez détendu(e).',
                  style: TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Measurements
          _buildMeasurementField(
            'Tour de cou',
            _neckController,
            'cm',
            Icons.face,
          ),
          const SizedBox(height: 16),

          _buildMeasurementField(
            'Tour de taille (abdomen)',
            _waistController,
            'cm',
            Icons.accessibility,
          ),
          const SizedBox(height: 16),

          if (profile?.gender.toLowerCase() == 'female')
            _buildMeasurementField(
              'Tour de hanches',
              _hipsController,
              'cm',
              Icons.accessibility_new,
            ),

          const SizedBox(height: 24),

          // Calculate button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: _calculateBodyFat,
              icon: const Icon(Icons.calculate),
              label: const Text(
                'Calculer Body Fat %',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Result
          if (_calculatedBodyFat != null) ...[
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade400,
                    Colors.deepOrange.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Votre Body Fat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${_calculatedBodyFat!.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _interpretBodyFat(_calculatedBodyFat!, profile?.gender ?? 'male'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (profile != null) ...[
              _buildResultCard(
                title: 'Masse maigre',
                value: '${FitnessCalculators.calculateLeanBodyMass(weight: profile.currentWeight, bodyFatPercentage: _calculatedBodyFat!).toStringAsFixed(1)} kg',
                subtitle: 'Muscles, os, organes',
                icon: Icons.fitness_center,
                color: Colors.green,
              ),
              const SizedBox(height: 12),

              _buildResultCard(
                title: 'Masse grasse',
                value: '${FitnessCalculators.calculateFatMass(weight: profile.currentWeight, bodyFatPercentage: _calculatedBodyFat!).toStringAsFixed(1)} kg',
                subtitle: 'Graisse corporelle',
                icon: Icons.water_drop,
                color: Colors.orange,
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMeasurementField(
    String label,
    TextEditingController controller,
    String unit,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: '0',
                hintStyle: TextStyle(color: Colors.grey[400]),
                suffixText: unit,
                suffixStyle: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, int value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          '$value g',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _interpretBodyFat(double bodyFat, String gender) {
    if (gender.toLowerCase() == 'male') {
      if (bodyFat < 6) return 'Essentiel';
      if (bodyFat < 14) return 'Athlète';
      if (bodyFat < 18) return 'Fitness';
      if (bodyFat < 25) return 'Acceptable';
      return 'Obésité';
    } else {
      if (bodyFat < 14) return 'Essentiel';
      if (bodyFat < 21) return 'Athlète';
      if (bodyFat < 25) return 'Fitness';
      if (bodyFat < 32) return 'Acceptable';
      return 'Obésité';
    }
  }
}
