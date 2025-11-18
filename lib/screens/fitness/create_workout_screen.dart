import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';
import 'exercise_selector_screen.dart';

/// Écran pour créer ou modifier une séance d'entraînement
class CreateWorkoutScreen extends StatefulWidget {
  final Workout? workoutToEdit;

  const CreateWorkoutScreen({super.key, this.workoutToEdit});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _uuid = const Uuid();
  late TextEditingController _nameController;
  late List<WorkoutExercise> _selectedExercises;
  bool _isEditMode = false;
  int _defaultRestSeconds = 120; // 2 minutes par défaut

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.workoutToEdit != null;
    _nameController = TextEditingController(
      text: widget.workoutToEdit?.name ?? 'Séance du ${DateTime.now().day}/${DateTime.now().month}',
    );
    _selectedExercises = widget.workoutToEdit?.exercises.map((e) => e).toList() ?? [];
    _defaultRestSeconds = widget.workoutToEdit?.defaultRestSeconds ?? 120;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addExercise(Exercise exercise) {
    setState(() {
      _selectedExercises.add(
        WorkoutExercise(
          id: _uuid.v4(),
          exercise: exercise,
          sets: List.generate(
            3, // 3 séries par défaut
            (index) => WorkoutSet(
              id: _uuid.v4(),
              weight: 0,
              reps: 10,
              restSeconds: _defaultRestSeconds, // Utiliser le temps de repos global
            ),
          ),
          order: _selectedExercises.length,
        ),
      );
    });
  }

  void _removeExercise(int index) {
    setState(() {
      _selectedExercises.removeAt(index);
      // Réorganiser les ordres
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = WorkoutExercise(
          id: _selectedExercises[i].id,
          exercise: _selectedExercises[i].exercise,
          sets: _selectedExercises[i].sets,
          order: i,
          notes: _selectedExercises[i].notes,
        );
      }
    });
  }

  void _reorderExercises(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _selectedExercises.removeAt(oldIndex);
      _selectedExercises.insert(newIndex, item);
      // Mettre à jour les ordres
      for (int i = 0; i < _selectedExercises.length; i++) {
        _selectedExercises[i] = WorkoutExercise(
          id: _selectedExercises[i].id,
          exercise: _selectedExercises[i].exercise,
          sets: _selectedExercises[i].sets,
          order: i,
          notes: _selectedExercises[i].notes,
        );
      }
    });
  }

  void _updateSet(int exerciseIndex, int setIndex, WorkoutSet updatedSet) {
    setState(() {
      _selectedExercises[exerciseIndex].sets[setIndex] = updatedSet;
    });
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      final lastSet = _selectedExercises[exerciseIndex].sets.last;
      _selectedExercises[exerciseIndex].sets.add(
        WorkoutSet(
          id: _uuid.v4(),
          weight: lastSet.weight,
          reps: lastSet.reps,
          restSeconds: lastSet.restSeconds,
        ),
      );
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    setState(() {
      if (_selectedExercises[exerciseIndex].sets.length > 1) {
        _selectedExercises[exerciseIndex].sets.removeAt(setIndex);
      }
    });
  }

  void _updateGlobalRestTime(int newRestSeconds) {
    // Valider les limites
    if (newRestSeconds < 30 || newRestSeconds > 300) return;

    setState(() {
      _defaultRestSeconds = newRestSeconds;

      // Mettre à jour tous les sets non-modifiés
      for (int i = 0; i < _selectedExercises.length; i++) {
        final exercise = _selectedExercises[i];
        final updatedSets = exercise.sets.map((set) {
          // Ne mettre à jour que les sets dont le temps de repos n'a pas été modifié manuellement
          if (!set.isRestTimeModified) {
            return set.copyWith(restSeconds: newRestSeconds);
          }
          return set;
        }).toList();

        _selectedExercises[i] = WorkoutExercise(
          id: exercise.id,
          exercise: exercise.exercise,
          sets: updatedSets,
          order: exercise.order,
          notes: exercise.notes,
        );
      }
    });
  }

  void _saveWorkout() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez donner un nom à votre séance')),
      );
      return;
    }

    if (_selectedExercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez ajouter au moins un exercice')),
      );
      return;
    }

    final workout = Workout(
      id: widget.workoutToEdit?.id ?? _uuid.v4(),
      name: _nameController.text,
      exercises: _selectedExercises,
      defaultRestSeconds: _defaultRestSeconds,
    );

    final provider = context.read<FitnessProvider>();
    if (_isEditMode) {
      provider.updateWorkout(workout);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séance mise à jour !')),
      );
    } else {
      provider.saveWorkout(workout);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Séance enregistrée !')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier la séance' : 'Créer une séance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveWorkout,
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration de la séance
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Nom de la séance
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de la séance',
                    prefixIcon: Icon(Icons.edit),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Temps de repos global
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.timer, size: 20, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          const Text(
                            'Temps de repos global',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Temps par défaut entre chaque série (modifiable individuellement)',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              _updateGlobalRestTime(_defaultRestSeconds - 15);
                            },
                            icon: const Icon(Icons.remove_circle_outline),
                            color: AppTheme.primaryColor,
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${(_defaultRestSeconds / 60).floor()}m ${_defaultRestSeconds % 60}s',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _updateGlobalRestTime(_defaultRestSeconds + 15);
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            color: AppTheme.primaryColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Liste des exercices
          Expanded(
            child: _selectedExercises.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Aucun exercice sélectionné',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final exercise = await Navigator.push<Exercise>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExerciseSelectorScreen(),
                              ),
                            );
                            if (exercise != null) {
                              _addExercise(exercise);
                            }
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un exercice'),
                        ),
                      ],
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _selectedExercises.length,
                    onReorder: _reorderExercises,
                    itemBuilder: (context, index) {
                      final workoutExercise = _selectedExercises[index];
                      return _buildExerciseCard(workoutExercise, index);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: _selectedExercises.isNotEmpty
          ? FloatingActionButton(
              onPressed: () async {
                final exercise = await Navigator.push<Exercise>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ExerciseSelectorScreen(),
                  ),
                );
                if (exercise != null) {
                  _addExercise(exercise);
                }
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildExerciseCard(WorkoutExercise workoutExercise, int exerciseIndex) {
    return Card(
      key: ValueKey(workoutExercise.id),
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: ReorderableDragStartListener(
          index: exerciseIndex,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getMuscleGroupColor(workoutExercise.exercise.category).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.drag_handle,
              color: AppTheme.getMuscleGroupColor(workoutExercise.exercise.category),
            ),
          ),
        ),
        title: Text(workoutExercise.exercise.name),
        subtitle: Text('${workoutExercise.sets.length} séries'),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _removeExercise(exerciseIndex),
        ),
        children: [
          // Liste des séries
          ...workoutExercise.sets.asMap().entries.map((entry) {
            final setIndex = entry.key;
            final set = entry.value;
            return _buildSetRow(exerciseIndex, setIndex, set);
          }),

          // Bouton ajouter série
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextButton.icon(
              onPressed: () => _addSet(exerciseIndex),
              icon: const Icon(Icons.add),
              label: const Text('Ajouter une série'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(int exerciseIndex, int setIndex, WorkoutSet set) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Numéro de série
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Text(
              '${setIndex + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),

          // Poids
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Poids (kg)',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: set.weight.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: set.weight.toString().length),
                ),
              onChanged: (value) {
                final weight = double.tryParse(value) ?? 0;
                _updateSet(
                  exerciseIndex,
                  setIndex,
                  set.copyWith(weight: weight),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Reps
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: set.reps.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: set.reps.toString().length),
                ),
              onChanged: (value) {
                final reps = int.tryParse(value) ?? 0;
                _updateSet(
                  exerciseIndex,
                  setIndex,
                  set.copyWith(reps: reps),
                );
              },
            ),
          ),
          const SizedBox(width: 8),

          // Repos (secondes)
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Repos (s)',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              controller: TextEditingController(text: set.restSeconds.toString())
                ..selection = TextSelection.fromPosition(
                  TextPosition(offset: set.restSeconds.toString().length),
                ),
              onChanged: (value) {
                final rest = int.tryParse(value) ?? 120;
                _updateSet(
                  exerciseIndex,
                  setIndex,
                  set.copyWith(
                    restSeconds: rest,
                    isRestTimeModified: true, // Marquer comme modifié manuellement
                  ),
                );
              },
            ),
          ),

          // Supprimer série
          if (_selectedExercises[exerciseIndex].sets.length > 1)
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
              onPressed: () => _removeSet(exerciseIndex, setIndex),
            ),
        ],
      ),
    );
  }
}
