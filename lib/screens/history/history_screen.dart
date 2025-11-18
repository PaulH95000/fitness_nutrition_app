import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
      future: DatabaseService.instance.getWeightHistory(30),
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
    return Consumer<NutritionProvider>(
      builder: (context, provider, child) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Historique des calories en développement...\nUtilisez l\'onglet Nutrition pour voir les calories du jour.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepsTab() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Suivi des pas en développement...\nNécessite intégration HealthKit iOS.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
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
