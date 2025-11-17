import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';

/// Écran de sélection d'exercices avec recherche avancée et filtres
class ExerciseSelectorScreen extends StatefulWidget {
  final String? initialCategory;

  const ExerciseSelectorScreen({super.key, this.initialCategory});

  @override
  State<ExerciseSelectorScreen> createState() => _ExerciseSelectorScreenState();
}

class _ExerciseSelectorScreenState extends State<ExerciseSelectorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCategory;
  String? _selectedEquipment;
  String? _selectedDifficulty;
  bool _showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Exercise> _filterExercises(List<Exercise> exercises) {
    return exercises.where((exercise) {
      // Filtre par recherche
      if (_searchController.text.isNotEmpty) {
        final query = _searchController.text.toLowerCase();
        if (!exercise.name.toLowerCase().contains(query) &&
            !exercise.muscleGroups.any((m) => m.toLowerCase().contains(query))) {
          return false;
        }
      }

      // Filtre par catégorie
      if (_selectedCategory != null && exercise.category != _selectedCategory) {
        return false;
      }

      // Filtre par équipement
      if (_selectedEquipment != null && exercise.equipment != _selectedEquipment) {
        return false;
      }

      // Filtre par difficulté
      if (_selectedDifficulty != null && exercise.difficulty != _selectedDifficulty) {
        return false;
      }

      // Filtre par favoris
      if (_showFavoritesOnly && !exercise.isFavorite) {
        return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sélectionner un exercice'),
        actions: [
          IconButton(
            icon: Icon(
              _showFavoritesOnly ? Icons.favorite : Icons.favorite_border,
              color: _showFavoritesOnly ? Colors.red : null,
            ),
            onPressed: () {
              setState(() {
                _showFavoritesOnly = !_showFavoritesOnly;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un exercice...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filtres
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  'Catégorie',
                  _selectedCategory,
                  ['chest', 'back', 'legs', 'shoulders', 'arms', 'core', 'cardio'],
                  {
                    'chest': 'Pectoraux',
                    'back': 'Dos',
                    'legs': 'Jambes',
                    'shoulders': 'Épaules',
                    'arms': 'Bras',
                    'core': 'Abdos',
                    'cardio': 'Cardio',
                  },
                  (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Équipement',
                  _selectedEquipment,
                  ['barbell', 'dumbbell', 'machine', 'bodyweight', 'cable'],
                  {
                    'barbell': 'Barre',
                    'dumbbell': 'Haltères',
                    'machine': 'Machine',
                    'bodyweight': 'Poids du corps',
                    'cable': 'Câbles',
                  },
                  (value) => setState(() => _selectedEquipment = value),
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Niveau',
                  _selectedDifficulty,
                  ['beginner', 'intermediate', 'advanced'],
                  {
                    'beginner': 'Débutant',
                    'intermediate': 'Intermédiaire',
                    'advanced': 'Avancé',
                  },
                  (value) => setState(() => _selectedDifficulty = value),
                ),
              ],
            ),
          ),

          // Liste des exercices filtrés
          Expanded(
            child: Consumer<FitnessProvider>(
              builder: (context, provider, child) {
                final filteredExercises = _filterExercises(provider.exercises);

                if (filteredExercises.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun exercice trouvé',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _selectedCategory = null;
                              _selectedEquipment = null;
                              _selectedDifficulty = null;
                              _showFavoritesOnly = false;
                            });
                          },
                          child: const Text('Réinitialiser les filtres'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredExercises.length,
                  itemBuilder: (context, index) {
                    final exercise = filteredExercises[index];
                    return _buildExerciseCard(context, exercise, provider);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String? selectedValue,
    List<String> options,
    Map<String, String> labels,
    Function(String?) onChanged,
  ) {
    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(selectedValue != null ? labels[selectedValue]! : label),
          if (selectedValue != null) ...[
            const SizedBox(width: 4),
            const Icon(Icons.close, size: 16),
          ],
        ],
      ),
      selected: selectedValue != null,
      onSelected: (selected) {
        if (selected) {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    ...options.map((option) {
                      return ListTile(
                        title: Text(labels[option]!),
                        trailing: selectedValue == option
                            ? const Icon(Icons.check, color: AppTheme.accentColor)
                            : null,
                        onTap: () {
                          onChanged(option);
                          Navigator.pop(context);
                        },
                      );
                    }),
                    const SizedBox(height: 8),
                  ],
                ),
              );
            },
          );
        } else {
          onChanged(null);
        }
      },
    );
  }

  Widget _buildExerciseCard(BuildContext context, Exercise exercise, FitnessProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context, exercise);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icône de catégorie
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.getMuscleGroupColor(exercise.category).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      color: AppTheme.getMuscleGroupColor(exercise.category),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Nom et infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          exercise.muscleGroups.join(', '),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  // Favori
                  IconButton(
                    icon: Icon(
                      exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: exercise.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      provider.toggleExerciseFavorite(exercise.id);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _buildTag(
                    _getEquipmentLabel(exercise.equipment),
                    AppTheme.accentColor.withOpacity(0.1),
                    AppTheme.accentColor,
                  ),
                  _buildTag(
                    _getDifficultyLabel(exercise.difficulty),
                    _getDifficultyColor(exercise.difficulty).withOpacity(0.1),
                    _getDifficultyColor(exercise.difficulty),
                  ),
                  if (exercise.videoUrl != null)
                    _buildTag(
                      '📹 Vidéo',
                      AppTheme.primaryColor.withOpacity(0.1),
                      AppTheme.primaryColor,
                    ),
                ],
              ),

              // Description (si disponible)
              if (exercise.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  exercise.description!,
                  style: TextStyle(color: Colors.grey[700], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Lien vidéo (si disponible)
              if (exercise.videoUrl != null) ...[
                const SizedBox(height: 8),
                InkWell(
                  onTap: () {
                    // Ouvrir la vidéo dans un navigateur ou player
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Ouvrir: ${exercise.videoUrl}'),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.play_circle_outline, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          exercise.videoUrl!,
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _getEquipmentLabel(String equipment) {
    const labels = {
      'barbell': 'Barre',
      'dumbbell': 'Haltères',
      'machine': 'Machine',
      'bodyweight': 'Poids du corps',
      'cable': 'Câbles',
    };
    return labels[equipment] ?? equipment;
  }

  String _getDifficultyLabel(String difficulty) {
    const labels = {
      'beginner': 'Débutant',
      'intermediate': 'Intermédiaire',
      'advanced': 'Avancé',
    };
    return labels[difficulty] ?? difficulty;
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return AppTheme.successColor;
      case 'intermediate':
        return AppTheme.warningColor;
      case 'advanced':
        return AppTheme.errorColor;
      default:
        return AppTheme.primaryColor;
    }
  }
}
