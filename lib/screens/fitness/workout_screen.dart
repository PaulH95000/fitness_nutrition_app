import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';
import 'package:uuid/uuid.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final _uuid = const Uuid();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Séance d\'entraînement'),
        actions: [
          Consumer<FitnessProvider>(
            builder: (context, provider, child) {
              if (provider.hasActiveWorkout) {
                return IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: () => _completeWorkout(context, provider),
                );
              }
              return Container();
            },
          ),
        ],
      ),
      body: Consumer<FitnessProvider>(
        builder: (context, provider, child) {
          if (!provider.hasActiveWorkout) {
            return _buildStartWorkoutView(context, provider);
          }
          
          return _buildActiveWorkoutView(context, provider);
        },
      ),
    );
  }

  Widget _buildStartWorkoutView(BuildContext context, FitnessProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 80, color: AppTheme.primaryColor),
          const SizedBox(height: 24),
          Text(
            'Créer une nouvelle séance',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showExerciseSelection(context, provider),
            icon: const Icon(Icons.add),
            label: const Text('Sélectionner les exercices'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkoutView(BuildContext context, FitnessProvider provider) {
    final workout = provider.currentWorkout!;
    
    return Column(
      children: [
        // En-tête avec progression
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.primaryColor.withOpacity(0.1),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    workout.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${workout.completedSets} / ${workout.totalSets}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: workout.progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                minHeight: 8,
              ),
            ],
          ),
        ),
        
        // Liste des exercices
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: workout.exercises.length,
            itemBuilder: (context, index) {
              final exercise = workout.exercises[index];
              return _buildExerciseCard(context, provider, exercise);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseCard(BuildContext context, FitnessProvider provider, WorkoutExercise workoutExercise) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.getMuscleGroupColor(workoutExercise.exercise.category).withOpacity(0.2),
          child: Icon(
            Icons.fitness_center,
            color: AppTheme.getMuscleGroupColor(workoutExercise.exercise.category),
          ),
        ),
        title: Text(workoutExercise.exercise.name),
        subtitle: Text(
          '${workoutExercise.completedSets} / ${workoutExercise.sets.length} séries',
        ),
        trailing: workoutExercise.isCompleted
            ? const Icon(Icons.check_circle, color: AppTheme.accentColor)
            : null,
        children: [
          // Afficher l'historique
          FutureBuilder<List<WorkoutHistory>>(
            future: provider.getExerciseHistory(workoutExercise.exercise.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final lastWorkout = snapshot.data!.first;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.history, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Dernière performance',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ...lastWorkout.sets.asMap().entries.map((entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Text(
                          'Série ${entry.key + 1}: ${entry.value.weight}kg × ${entry.value.reps} reps',
                          style: const TextStyle(fontSize: 12),
                        ),
                      )),
                    ],
                  ),
                );
              }
              return Container();
            },
          ),
          const SizedBox(height: 8),
          
          // Liste des séries
          ...workoutExercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            
            return ListTile(
              leading: Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: set.completed ? AppTheme.accentColor : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${setIndex + 1}',
                  style: TextStyle(
                    color: set.completed ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Poids',
                        suffixText: 'kg',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: set.weight.toString()),
                      onSubmitted: (value) {
                        final weight = double.tryParse(value);
                        if (weight != null) {
                          provider.updateSet(
                            workoutExercise.id,
                            setIndex,
                            set.copyWith(weight: weight),
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 80,
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        isDense: true,
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(text: set.reps.toString()),
                      onSubmitted: (value) {
                        final reps = int.tryParse(value);
                        if (reps != null) {
                          provider.updateSet(
                            workoutExercise.id,
                            setIndex,
                            set.copyWith(reps: reps),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
              trailing: set.completed
                  ? IconButton(
                      icon: const Icon(Icons.check_circle, color: AppTheme.accentColor),
                      onPressed: () {
                        provider.updateSet(
                          workoutExercise.id,
                          setIndex,
                          set.copyWith(completed: false),
                        );
                      },
                    )
                  : ElevatedButton(
                      onPressed: () {
                        provider.completeSet(workoutExercise.id, setIndex);
                      },
                      child: const Text('Terminé'),
                    ),
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showExerciseSelection(BuildContext context, FitnessProvider provider) {
    final selectedExercises = <Exercise>[];
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sélectionner les exercices',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        ElevatedButton(
                          onPressed: selectedExercises.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(context);
                                  _createWorkout(context, provider, selectedExercises);
                                },
                          child: Text('Démarrer (${selectedExercises.length})'),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      controller: scrollController,
                      itemCount: provider.exercises.length,
                      itemBuilder: (context, index) {
                        final exercise = provider.exercises[index];
                        final isSelected = selectedExercises.contains(exercise);
                        
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (selected) {
                            setModalState(() {
                              if (selected == true) {
                                selectedExercises.add(exercise);
                              } else {
                                selectedExercises.remove(exercise);
                              }
                            });
                          },
                          secondary: CircleAvatar(
                            backgroundColor: AppTheme.getMuscleGroupColor(exercise.category).withOpacity(0.2),
                            child: Icon(
                              Icons.fitness_center,
                              color: AppTheme.getMuscleGroupColor(exercise.category),
                            ),
                          ),
                          title: Text(exercise.name),
                          subtitle: Text(exercise.muscleGroups.join(', ')),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _createWorkout(BuildContext context, FitnessProvider provider, List<Exercise> exercises) {
    final workoutExercises = exercises.asMap().entries.map((entry) {
      return WorkoutExercise(
        id: _uuid.v4(),
        exercise: entry.value,
        sets: List.generate(
          3, // 3 séries par défaut
          (index) => WorkoutSet(
            id: _uuid.v4(),
            weight: 0,
            reps: 10,
          ),
        ),
        order: entry.key,
      );
    }).toList();
    
    provider.startWorkout('Séance du ${DateTime.now().day}/${DateTime.now().month}', workoutExercises);
  }

  void _completeWorkout(BuildContext context, FitnessProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terminer la séance'),
        content: const Text('Voulez-vous enregistrer cette séance ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.completeWorkout();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Séance terminée !')),
                );
              }
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }
}
