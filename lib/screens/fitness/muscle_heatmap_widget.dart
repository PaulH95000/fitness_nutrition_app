import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Widget de heatmap des muscles (style Hevy)
/// Plus clair et moderne que le CustomPainter
class MuscleHeatmapWidget extends StatelessWidget {
  final Map<String, int> muscleGroups;

  const MuscleHeatmapWidget({super.key, required this.muscleGroups});

  int _getIntensity(List<String> muscleKeys) {
    int maxIntensity = 0;
    for (var key in muscleKeys) {
      for (var entry in muscleGroups.entries) {
        if (entry.key.toLowerCase().contains(key.toLowerCase()) ||
            key.toLowerCase().contains(entry.key.toLowerCase())) {
          if (entry.value > maxIntensity) {
            maxIntensity = entry.value;
          }
        }
      }
    }
    return maxIntensity;
  }

  Color _getColorForIntensity(int intensity) {
    if (intensity == 0) return Colors.grey[200]!;
    if (intensity <= 2) return AppTheme.primaryColor.withOpacity(0.3);
    if (intensity <= 4) return AppTheme.primaryColor.withOpacity(0.5);
    if (intensity <= 6) return AppTheme.primaryColor.withOpacity(0.7);
    return AppTheme.primaryColor;
  }

  @override
  Widget build(BuildContext context) {
    final frontMuscles = [
      {'name': 'Pectoraux', 'keys': ['pectoraux', 'chest'], 'icon': Icons.fitness_center},
      {'name': 'Deltoïdes avant', 'keys': ['deltoïdes', 'épaules', 'shoulders'], 'icon': Icons.sports_gymnastics},
      {'name': 'Biceps', 'keys': ['biceps'], 'icon': Icons.sports_martial_arts},
      {'name': 'Abdominaux', 'keys': ['abdominaux', 'core', 'abs'], 'icon': Icons.whatshot},
      {'name': 'Quadriceps', 'keys': ['quadriceps', 'quadri'], 'icon': Icons.directions_run},
      {'name': 'Avant-bras', 'keys': ['avant-bras', 'forearm'], 'icon': Icons.pan_tool},
    ];

    final backMuscles = [
      {'name': 'Trapèzes', 'keys': ['trapèzes', 'trap'], 'icon': Icons.fitness_center},
      {'name': 'Dorsaux', 'keys': ['dorsaux', 'back', 'lats'], 'icon': Icons.accessibility_new},
      {'name': 'Deltoïdes arrière', 'keys': ['deltoïdes', 'épaules', 'shoulders'], 'icon': Icons.sports_gymnastics},
      {'name': 'Triceps', 'keys': ['triceps'], 'icon': Icons.sports_martial_arts},
      {'name': 'Lombaires', 'keys': ['lombaires', 'lower back'], 'icon': Icons.whatshot},
      {'name': 'Fessiers', 'keys': ['fessiers', 'glutes'], 'icon': Icons.airline_seat_recline_normal},
      {'name': 'Ischio-jambiers', 'keys': ['ischio', 'hamstrings'], 'icon': Icons.directions_run},
    ];

    return Column(
      children: [
        // Front view
        _buildMuscleSection(context, 'Vue de face', frontMuscles),
        const SizedBox(height: 20),
        // Back view
        _buildMuscleSection(context, 'Vue de dos', backMuscles),
        const SizedBox(height: 16),
        // Legend
        _buildLegend(),
      ],
    );
  }

  Widget _buildMuscleSection(BuildContext context, String title, List<Map<String, dynamic>> muscles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: muscles.map((muscle) {
            final intensity = _getIntensity(muscle['keys'] as List<String>);
            final color = _getColorForIntensity(intensity);

            return Container(
              width: (MediaQuery.of(context).size.width - 48) / 2,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: intensity > 0 ? AppTheme.primaryColor : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    muscle['icon'] as IconData,
                    color: intensity > 0 ? Colors.white : Colors.grey[400],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          muscle['name'] as String,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: intensity > 0 ? Colors.white : Colors.grey[700],
                            fontSize: 12,
                          ),
                        ),
                        if (intensity > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            '$intensity série${intensity > 1 ? 's' : ''}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('Repos', Colors.grey[200]!),
          _buildLegendItem('Léger', AppTheme.primaryColor.withOpacity(0.3)),
          _buildLegendItem('Modéré', AppTheme.primaryColor.withOpacity(0.6)),
          _buildLegendItem('Intense', AppTheme.primaryColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11),
        ),
      ],
    );
  }
}
