import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Plate Calculator - Calculateur de plaques de poids
/// Feature populaire de Hevy pour savoir combien de plaques mettre sur la barre
class PlateCalculatorScreen extends StatefulWidget {
  const PlateCalculatorScreen({super.key});

  @override
  State<PlateCalculatorScreen> createState() => _PlateCalculatorScreenState();
}

class _PlateCalculatorScreenState extends State<PlateCalculatorScreen> {
  final TextEditingController _weightController = TextEditingController();
  double _barWeight = 20.0; // Poids de la barre en kg (standard olympique)
  List<PlateCount> _plates = [];

  // Plaques disponibles (en kg, par ordre décroissant)
  final List<double> _availablePlates = [25, 20, 15, 10, 5, 2.5, 1.25, 0.5];

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  void _calculatePlates() {
    final totalWeight = double.tryParse(_weightController.text);
    if (totalWeight == null || totalWeight <= _barWeight) {
      setState(() {
        _plates = [];
      });
      return;
    }

    // Poids à répartir sur les deux côtés (moins le poids de la barre)
    double remainingWeight = (totalWeight - _barWeight) / 2;

    List<PlateCount> result = [];
    for (var plate in _availablePlates) {
      if (remainingWeight >= plate) {
        int count = (remainingWeight / plate).floor();
        result.add(PlateCount(weight: plate, count: count));
        remainingWeight -= (plate * count);
      }
    }

    setState(() {
      _plates = result;
    });
  }

  Color _getPlateColor(double weight) {
    if (weight >= 20) return Colors.blue;
    if (weight >= 15) return Colors.yellow[700]!;
    if (weight >= 10) return Colors.green;
    if (weight >= 5) return Colors.white;
    if (weight >= 2.5) return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Calculateur de Plaques',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.accentColor.withOpacity(0.1),
                    AppTheme.accentColor.withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.calculate, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Calculez combien de plaques mettre de chaque côté de votre barre',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Bar weight selector
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poids de la barre',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildBarWeightButton(20.0, 'Olympique\n20 kg'),
                      const SizedBox(width: 12),
                      _buildBarWeightButton(15.0, 'Femmes\n15 kg'),
                      const SizedBox(width: 12),
                      _buildBarWeightButton(10.0, 'EZ\n10 kg'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Weight input
            Container(
              padding: const EdgeInsets.all(20),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Poids total souhaité',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      hintText: 'Ex: 100',
                      suffixText: 'kg',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 2),
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _calculatePlates(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Result
            if (_plates.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(20),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Plaques par côté',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 20),

                    // Visual representation
                    _buildBarVisualization(),

                    const SizedBox(height: 20),

                    // Plate list
                    ..._plates.map((plateCount) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getPlateColor(plateCount.weight).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getPlateColor(plateCount.weight).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _getPlateColor(plateCount.weight),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '${plateCount.weight}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: plateCount.weight >= 5 ? Colors.black : Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Plaque de ${plateCount.weight} kg',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${plateCount.count} plaque${plateCount.count > 1 ? 's' : ''}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '× ${plateCount.count}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 16),

                    // Total calculation
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.successColor.withOpacity(0.1),
                            AppTheme.successColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total par côté:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${_plates.fold<double>(0, (sum, p) => sum + (p.weight * p.count))} kg',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.successColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBarWeightButton(double weight, String label) {
    final isSelected = _barWeight == weight;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _barWeight = weight;
            _calculatePlates();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarVisualization() {
    return Container(
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bar
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Left side plates
          Positioned(
            left: 0,
            child: Row(
              children: _plates.map((plateCount) {
                return Row(
                  children: List.generate(plateCount.count, (index) {
                    return Container(
                      width: 20,
                      height: 60 - (20 - plateCount.weight),
                      margin: const EdgeInsets.only(right: 2),
                      decoration: BoxDecoration(
                        color: _getPlateColor(plateCount.weight),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
          // Right side plates
          Positioned(
            right: 0,
            child: Row(
              children: _plates.map((plateCount) {
                return Row(
                  children: List.generate(plateCount.count, (index) {
                    return Container(
                      width: 20,
                      height: 60 - (20 - plateCount.weight),
                      margin: const EdgeInsets.only(left: 2),
                      decoration: BoxDecoration(
                        color: _getPlateColor(plateCount.weight),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                    );
                  }),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class PlateCount {
  final double weight;
  final int count;

  PlateCount({required this.weight, required this.count});
}
