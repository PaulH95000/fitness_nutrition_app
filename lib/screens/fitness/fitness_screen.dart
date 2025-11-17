import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../core/theme/app_theme.dart';
import 'saved_workouts_screen.dart';
import 'create_workout_screen.dart';
import 'body_visualization_widget.dart';
import 'exercise_selector_screen.dart';

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
            icon: const Icon(Icons.fitness_center),
            tooltip: 'Mes entraînements',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedWorkoutsScreen()),
              );
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
                // Séance en cours ou Call-to-action
                if (provider.hasActiveWorkout)
                  _buildActiveWorkoutCard(context, provider)
                else
                  _buildEmptyStateCard(context),

                const SizedBox(height: 24),

                // Statistiques rapides
                _buildQuickStats(context, provider),

                const SizedBox(height: 24),

                // Visualisation du corps
                if (provider.currentWorkout != null) ...[
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
                          BodyVisualizationWidget(
                            muscleGroups: provider.getMuscleGroupIntensity(provider.currentWorkout!),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Mes séances sauvegardées
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mes entraînements',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SavedWorkoutsScreen()),
                        );
                      },
                      child: const Text('Voir tout'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (provider.savedWorkoutTemplates.isEmpty)
                  _buildNoWorkoutsCard(context)
                else
                  ...provider.savedWorkoutTemplates.take(3).map((workout) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.fitness_center, color: AppTheme.primaryColor),
                        ),
                        title: Text(workout.name),
                        subtitle: Text('${workout.exercises.length} exercices • ${workout.totalSets} séries'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SavedWorkoutsScreen()),
                          );
                        },
                      ),
                    );
                  }),

                const SizedBox(height: 24),

                // Exercices par catégorie
                Text(
                  'Exercices par catégorie',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),

                _buildCategoryCard(
                  context,
                  'Pectoraux',
                  Icons.fitness_center,
                  AppTheme.chestColor,
                  provider.getExercisesByCategory('chest').length,
                  'chest',
                ),
                const SizedBox(height: 8),

                _buildCategoryCard(
                  context,
                  'Dos',
                  Icons.accessibility_new,
                  AppTheme.backColor,
                  provider.getExercisesByCategory('back').length,
                  'back',
                ),
                const SizedBox(height: 8),

                _buildCategoryCard(
                  context,
                  'Jambes',
                  Icons.directions_run,
                  AppTheme.legsColor,
                  provider.getExercisesByCategory('legs').length,
                  'legs',
                ),
                const SizedBox(height: 8),

                _buildCategoryCard(
                  context,
                  'Épaules',
                  Icons.hardware,
                  AppTheme.shouldersColor,
                  provider.getExercisesByCategory('shoulders').length,
                  'shoulders',
                ),
                const SizedBox(height: 8),

                _buildCategoryCard(
                  context,
                  'Bras',
                  Icons.sports_martial_arts,
                  AppTheme.armsColor,
                  provider.getExercisesByCategory('arms').length,
                  'arms',
                ),
                const SizedBox(height: 8),

                _buildCategoryCard(
                  context,
                  'Abdos',
                  Icons.whatshot,
                  AppTheme.coreColor,
                  provider.getExercisesByCategory('core').length,
                  'core',
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
            MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle séance'),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.fitness_center,
                size: 64,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Prêt à vous entraîner ?',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Créez votre première séance d\'entraînement personnalisée ou choisissez parmi vos séances sauvegardées',
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Créer une séance'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveWorkoutCard(BuildContext context, FitnessProvider provider) {
    final workout = provider.currentWorkout!;

    return Card(
      color: AppTheme.accentColor.withOpacity(0.1),
      child: InkWell(
        onTap: () {
          // TODO: Naviguer vers la séance en cours
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.play_arrow, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Séance en cours',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          workout.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: workout.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                minHeight: 8,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${workout.completedSets} / ${workout.totalSets} séries',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Reprendre la séance
                    },
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Continuer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context, FitnessProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Exercices',
            provider.exercises.length.toString(),
            Icons.fitness_center,
            AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            context,
            'Entraînements',
            provider.savedWorkoutTemplates.length.toString(),
            Icons.list,
            AppTheme.accentColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoWorkoutsCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.fitness_center_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun entraînement enregistré',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer mon premier'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, IconData icon, Color color, int count, String categoryId) {
    return Card(
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(title),
        subtitle: Text('$count exercices'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ExerciseSelectorScreen(initialCategory: categoryId),
            ),
          );
        },
      ),
    );
  }
}
