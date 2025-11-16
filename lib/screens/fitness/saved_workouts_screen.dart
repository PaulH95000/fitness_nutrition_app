import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';
import 'create_workout_screen.dart';
import 'workout_session_screen.dart';

/// Écran pour afficher et gérer les séances sauvegardées
class SavedWorkoutsScreen extends StatelessWidget {
  const SavedWorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes entraînements'),
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          if (provider.savedWorkoutTemplates.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fitness_center_outlined, size: 100, color: Colors.grey[400]),
                  const SizedBox(height: 24),
                  Text(
                    'Aucune séance enregistrée',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Créez votre première séance d\'entraînement !',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Créer une séance'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.savedWorkoutTemplates.length,
            itemBuilder: (context, index) {
              final workout = provider.savedWorkoutTemplates[index];
              return _buildWorkoutCard(context, workout, provider);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout, FitnessProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          _showWorkoutOptions(context, workout, provider);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${workout.exercises.length} exercices • ${workout.totalSets} séries',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () {
                      _showWorkoutOptions(context, workout, provider);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Aperçu des muscles travaillés
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: workout.muscleGroupsWorked.take(5).map((muscle) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.getMuscleGroupColor(muscle).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      muscle,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.getMuscleGroupColor(muscle).withOpacity(0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWorkoutOptions(BuildContext context, Workout workout, FitnessProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.play_arrow, color: AppTheme.successColor),
                title: const Text('Commencer la séance'),
                onTap: () {
                  Navigator.pop(context);
                  // Créer une copie de la séance template pour la session
                  final sessionWorkout = provider.startWorkoutFromTemplate(workout);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WorkoutSessionScreen(workout: sessionWorkout),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit, color: AppTheme.primaryColor),
                title: const Text('Modifier'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CreateWorkoutScreen(workoutToEdit: workout),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.content_copy, color: AppTheme.accentColor),
                title: const Text('Dupliquer'),
                onTap: () {
                  Navigator.pop(context);
                  provider.duplicateWorkout(workout);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Séance dupliquée !')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppTheme.errorColor),
                title: const Text('Supprimer'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(context, workout, provider);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Workout workout, FitnessProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la séance ?'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${workout.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteWorkout(workout.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Séance supprimée')),
              );
            },
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
