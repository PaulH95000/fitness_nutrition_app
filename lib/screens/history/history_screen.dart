import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../providers/user_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/database_service.dart';
import 'package:uuid/uuid.dart';

/// Écran d'historique : poids, calories, pas quotidiens
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uuid = const Uuid();

  // Pedometer
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?';
  String _steps = '0';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initPedometer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _initPedometer() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream.listen(_onPedestrianStatusChanged).onError(_onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_onStepCount).onError(_onStepCountError);
  }

  void _onStepCount(StepCount event) {
    if (mounted) {
      setState(() {
        // IMPORTANT: Sur iOS, event.steps représente le nombre cumulé de pas depuis le démarrage
        // de l'appareil (ou depuis minuit selon la config). Pour obtenir les vrais pas du jour,
        // il faudrait utiliser HealthKit directement via un package comme 'health' ou 'fit_kit'.
        // Pour l'instant, on affiche la valeur brute du pedometer.
        _steps = event.steps.toString();
        print('🚶 Steps received from pedometer: ${event.steps}');
      });
    }
  }

  void _onPedestrianStatusChanged(PedestrianStatus event) {
    if (mounted) {
      setState(() {
        _status = event.status;
      });
    }
  }

  void _onStepCountError(error) {
    print('Erreur compteur de pas: $error');
    if (mounted) {
      setState(() {
        _steps = 'Non disponible';
      });
    }
  }

  void _onPedestrianStatusError(error) {
    print('Erreur status piéton: $error');
    if (mounted) {
      setState(() {
        _status = 'Non disponible';
      });
    }
  }

  Future<void> _requestActivityPermission() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission accordée !'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      _initPedometer();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permission refusée. Activez-la dans les réglages.'),
          backgroundColor: Colors.red,
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
          'Historique',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryColor,
          tabs: const [
            Tab(icon: Icon(Icons.monitor_weight), text: 'Poids'),
            Tab(icon: Icon(Icons.local_fire_department), text: 'Calories'),
            Tab(icon: Icon(Icons.directions_walk), text: 'Pas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildWeightTab(),
          _buildCaloriesTab(),
          _buildStepsTab(),
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseService.instance.getWeightHistory(limit: 30),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final weightHistory = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton ajouter poids
              Card(
                elevation: 0,
                color: AppTheme.primaryColor.withOpacity(0.1),
                child: ListTile(
                  leading: const Icon(Icons.add_circle, color: AppTheme.primaryColor),
                  title: const Text(
                    'Ajouter mon poids du jour',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  onTap: () => _showAddWeightDialog(),
                ),
              ),

              const SizedBox(height: 24),

              if (weightHistory.isNotEmpty) ...[
                // Graphique
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
                      const Text(
                        'Évolution du poids (30 derniers jours)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: weightHistory.asMap().entries.map((entry) {
                                  return FlSpot(
                                    entry.key.toDouble(),
                                    entry.value['weight'] as double,
                                  );
                                }).toList(),
                                isCurved: true,
                                color: AppTheme.primaryColor,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Historique liste
                Container(
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
                    children: weightHistory.take(10).map((entry) {
                      final date = DateTime.parse(entry['recorded_at'] as String);
                      final weight = entry['weight'] as double;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.monitor_weight,
                            color: AppTheme.primaryColor,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE d MMM yyyy', 'fr_FR').format(date),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        trailing: Text(
                          '${weight.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Aucun historique de poids.\nAjoutez votre premier poids !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCaloriesTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _getCaloriesHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final caloriesHistory = snapshot.data ?? [];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Card(
                elevation: 0,
                color: Colors.orange.withOpacity(0.1),
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Historique des calories consommées sur les 30 derniers jours',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              if (caloriesHistory.isNotEmpty) ...[
                // Graphique
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
                      const Text(
                        'Consommation calorique',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 200,
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: true),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: true),
                            lineBarsData: [
                              LineChartBarData(
                                spots: caloriesHistory.asMap().entries.map((entry) {
                                  return FlSpot(
                                    entry.key.toDouble(),
                                    entry.value['calories'] as double,
                                  );
                                }).toList(),
                                isCurved: true,
                                color: Colors.orange,
                                barWidth: 3,
                                dotData: FlDotData(show: true),
                                belowBarData: BarAreaData(
                                  show: true,
                                  color: Colors.orange.withOpacity(0.1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Liste
                Container(
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
                    children: caloriesHistory.take(10).map((entry) {
                      final date = DateTime.parse(entry['date'] as String);
                      final calories = entry['calories'] as double;
                      final protein = entry['protein'] as double;
                      final carbs = entry['carbs'] as double;
                      final fat = entry['fat'] as double;

                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 24,
                          ),
                        ),
                        title: Text(
                          DateFormat('EEEE d MMM', 'fr_FR').format(date),
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          'P: ${protein.toInt()}g • G: ${carbs.toInt()}g • L: ${fat.toInt()}g',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        trailing: Text(
                          '${calories.toInt()} kcal',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ] else
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'Aucun historique de calories.\nAjoutez des repas dans l\'onglet Nutrition !',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getCaloriesHistory() async {
    final now = DateTime.now();
    final thirtyDaysAgo = now.subtract(const Duration(days: 30));

    final List<Map<String, dynamic>> result = [];

    // Récupérer les données pour chaque jour
    for (int i = 0; i < 30; i++) {
      final date = thirtyDaysAgo.add(Duration(days: i));
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final meals = await DatabaseService.instance.getMealEntriesByDateRange(
        startOfDay,
        endOfDay,
      );

      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;

      for (final meal in meals) {
        totalCalories += meal.totalCalories;
        totalProtein += meal.totalProtein;
        totalCarbs += meal.totalCarbs;
        totalFat += meal.totalFat;
      }

      if (totalCalories > 0) {
        result.add({
          'date': startOfDay.toIso8601String(),
          'calories': totalCalories,
          'protein': totalProtein,
          'carbs': totalCarbs,
          'fat': totalFat,
        });
      }
    }

    return result.reversed.toList(); // Plus récent en premier
  }

  Widget _buildStepsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte principal: Pas d'aujourd'hui
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.blue.shade600,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 60,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Pas aujourd\'hui',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _steps,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _status == 'walking' ? Icons.directions_walk : Icons.accessibility_new,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _status == 'walking'
                            ? 'En marche'
                            : _status == 'stopped'
                                ? 'Arrêté'
                                : _status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Objectif journalier
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
                const Text(
                  'Objectif journalier',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '10,000 pas',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: int.tryParse(_steps) != null
                                ? (int.parse(_steps) / 10000).clamp(0.0, 1.0)
                                : 0.0,
                            minHeight: 10,
                            backgroundColor: Colors.blue.withOpacity(0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            int.tryParse(_steps) != null
                                ? '${((int.parse(_steps) / 10000) * 100).toInt()}% de l\'objectif'
                                : '0% de l\'objectif',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Info & permissions
          if (_steps == 'Non disponible')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.info_outline, color: Colors.orange, size: 40),
                  const SizedBox(height: 12),
                  const Text(
                    'Compteur de pas non disponible',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pour utiliser cette fonctionnalité, autorisez l\'accès aux données de mouvement dans les réglages.',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _requestActivityPermission,
                    icon: const Icon(Icons.settings),
                    label: const Text('Autoriser l\'accès'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Statistiques
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
                const Text(
                  'Statistiques',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      label: 'Calories',
                      value: int.tryParse(_steps) != null
                          ? '${(int.parse(_steps) * 0.04).toInt()}'
                          : '0',
                      color: Colors.orange,
                    ),
                    _buildStatItem(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: int.tryParse(_steps) != null
                          ? '${(int.parse(_steps) * 0.0008).toStringAsFixed(1)} km'
                          : '0 km',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.schedule,
                      label: 'Temps actif',
                      value: int.tryParse(_steps) != null
                          ? '${(int.parse(_steps) / 100).toInt()} min'
                          : '0 min',
                      color: Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showAddWeightDialog() {
    final weightController = TextEditingController();
    final currentProfile = context.read<UserProvider>().userProfile;

    if (currentProfile != null) {
      weightController.text = currentProfile.currentWeight.toStringAsFixed(1);
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ajouter mon poids'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                hintText: 'Ex: 75.5',
                suffixText: 'kg',
                border: OutlineInputBorder(),
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
              final weight = double.tryParse(weightController.text);
              if (weight == null || weight <= 0 || weight > 300) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Poids invalide (0-300 kg)')),
                );
                return;
              }

              await DatabaseService.instance.insertWeightEntry(
                _uuid.v4(),
                weight,
                DateTime.now(),
              );

              // Mettre à jour le profil utilisateur avec le nouveau poids
              await context.read<UserProvider>().updateUserProfile(
                    currentWeight: weight,
                  );

              Navigator.pop(dialogContext);
              setState(() {}); // Refresh UI

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Poids enregistré !'),
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
}
