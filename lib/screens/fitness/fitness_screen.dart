import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../core/theme/app_theme.dart';
import 'workout_screen.dart';
import 'body_visualization_widget.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessProvider>().loadExercises();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              // Naviguer vers l'historique
            },
          ),
        ],
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Séance en cours
                if (provider.hasActiveWorkout)
                  _buildActiveWorkoutCard(context, provider),
                
                // Visualisation du corps
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Muscles travaillés',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        if (provider.currentWorkout != null)
                          BodyVisualizationWidget(
                            muscleGroups: provider.getMuscleGroupIntensity(provider.currentWorkout!),
                          )
                        else
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Commencez un entraînement pour voir les muscles travaillés',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Exercices par catégorie
                Text(
                  'Exercices',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                
                _buildCategoryCard(
                  context,
                  'Pectoraux',
                  Icons.fitness_center,
                  AppTheme.chestColor,
                  provider.getExercisesByCategory('chest'),
                ),
                const SizedBox(height: 8),
                
                _buildCategoryCard(
                  context,
                  'Dos',
                  Icons.accessibility_new,
                  AppTheme.backColor,
                  provider.getExercisesByCategory('back'),
                ),
                const SizedBox(height: 8),
                
                _buildCategoryCard(
                  context,
                  'Jambes',
                  Icons.directions_run,
                  AppTheme.legsColor,
                  provider.getExercisesByCategory('legs'),
                ),
                const SizedBox(height: 8),
                
                _buildCategoryCard(
                  context,
                  'Épaules',
                  Icons.hardware,
                  AppTheme.shouldersColor,
                  provider.getExercisesByCategory('shoulders'),
                ),
                const SizedBox(height: 8),
                
                _buildCategoryCard(
                  context,
                  'Bras',
                  Icons.sports_martial_arts,
                  AppTheme.armsColor,
                  provider.getExercisesByCategory('arms'),
                ),
                const SizedBox(height: 8),
                
                _buildCategoryCard(
                  context,
                  'Abdos',
                  Icons.whatshot,
                  AppTheme.coreColor,
                  provider.getExercisesByCategory('core'),
                ),
                
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
    );
  }

  Widget _buildActiveWorkoutCard(BuildContext context, FitnessProvider provider) {
    final workout = provider.currentWorkout!;
    
    return Card(
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const WorkoutScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Séance en cours',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: workout.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
              ),
              const SizedBox(height: 8),
              Text(
                '${workout.completedSets} / ${workout.totalSets} séries complétées',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, List exercises) {
    return Card(
      child: InkWell(
        onTap: () {
          _showExercisesList(context, title, exercises);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${exercises.length} exercices',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _showExercisesList(BuildContext context, String category, List exercises) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.getMuscleGroupColor(exercise.category).withOpacity(0.2),
                        child: Icon(
                          Icons.fitness_center,
                          color: AppTheme.getMuscleGroupColor(exercise.category),
                        ),
                      ),
                      title: Text(exercise.name),
                      subtitle: Text(exercise.muscleGroups.join(', ')),
                      trailing: IconButton(
                        icon: Icon(
                          exercise.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: exercise.isFavorite ? Colors.red : null,
                        ),
                        onPressed: () {
                          // Toggle favorite
                        },
                      ),
                      onTap: () async {
                        // Afficher l'historique de l'exercice
                        final history = await context.read<FitnessProvider>().getExerciseHistory(exercise.id);
                        if (context.mounted) {
                          _showExerciseHistory(context, exercise, history);
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExerciseHistory(BuildContext context, exercise, List history) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(exercise.name),
        content: SizedBox(
          width: double.maxFinite,
          child: history.isEmpty
              ? const Text('Aucun historique disponible')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final record = history[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          '${record.sets.length} séries',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...record.sets.map((set) => Text(
                              '${set.weight}kg × ${set.reps} reps',
                              style: const TextStyle(fontSize: 12),
                            )),
                          ],
                        ),
                        trailing: Text(
                          '${record.performedAt.day}/${record.performedAt.month}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
