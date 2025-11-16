import 'package:flutter/foundation.dart';
import '../models/workout_models.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class FitnessProvider extends ChangeNotifier {
  final _uuid = const Uuid();
  
  List<Exercise> _exercises = [];
  List<Exercise> _favoriteExercises = [];
  Workout? _currentWorkout;
  WorkoutProgram? _activeProgram;
  
  bool _isLoading = false;

  List<Exercise> get exercises => _exercises;
  List<Exercise> get favoriteExercises => _favoriteExercises;
  Workout? get currentWorkout => _currentWorkout;
  WorkoutProgram? get activeProgram => _activeProgram;
  bool get isLoading => _isLoading;
  bool get hasActiveWorkout => _currentWorkout != null && _currentWorkout!.isInProgress;

  Future<void> loadExercises() async {
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await DatabaseService.instance.getAllExercises();
      
      // Si aucun exercice, créer une base d'exercices par défaut
      if (_exercises.isEmpty) {
        await _createDefaultExercises();
        _exercises = await DatabaseService.instance.getAllExercises();
      }
      
      _favoriteExercises = _exercises.where((e) => e.isFavorite).toList();
    } catch (e) {
      print('Erreur lors du chargement des exercices: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _createDefaultExercises() async {
    final defaultExercises = [
      // Pectoraux
      Exercise(
        id: _uuid.v4(),
        name: 'Développé couché',
        category: 'chest',
        muscleGroups: ['pectoraux', 'triceps', 'deltoïdes antérieurs'],
        equipment: 'barbell',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Développé incliné',
        category: 'chest',
        muscleGroups: ['pectoraux supérieurs', 'deltoïdes antérieurs'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Pompes',
        category: 'chest',
        muscleGroups: ['pectoraux', 'triceps'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
      ),
      
      // Dos
      Exercise(
        id: _uuid.v4(),
        name: 'Tractions',
        category: 'back',
        muscleGroups: ['dorsaux', 'biceps', 'trapèzes'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Rowing barre',
        category: 'back',
        muscleGroups: ['dorsaux', 'trapèzes', 'biceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Tirage vertical',
        category: 'back',
        muscleGroups: ['dorsaux', 'biceps'],
        equipment: 'cable',
        difficulty: 'beginner',
      ),
      
      // Jambes
      Exercise(
        id: _uuid.v4(),
        name: 'Squat',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers', 'ischio-jambiers'],
        equipment: 'barbell',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Soulevé de terre',
        category: 'legs',
        muscleGroups: ['ischio-jambiers', 'fessiers', 'lombaires', 'trapèzes'],
        equipment: 'barbell',
        difficulty: 'advanced',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Presse à cuisses',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers'],
        equipment: 'machine',
        difficulty: 'beginner',
      ),
      
      // Épaules
      Exercise(
        id: _uuid.v4(),
        name: 'Développé militaire',
        category: 'shoulders',
        muscleGroups: ['deltoïdes', 'triceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Élévations latérales',
        category: 'shoulders',
        muscleGroups: ['deltoïdes latéraux'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
      ),
      
      // Bras
      Exercise(
        id: _uuid.v4(),
        name: 'Curl biceps',
        category: 'arms',
        muscleGroups: ['biceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Extensions triceps',
        category: 'arms',
        muscleGroups: ['triceps'],
        equipment: 'cable',
        difficulty: 'beginner',
      ),
      
      // Core
      Exercise(
        id: _uuid.v4(),
        name: 'Planche',
        category: 'core',
        muscleGroups: ['abdominaux', 'lombaires'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Crunchs',
        category: 'core',
        muscleGroups: ['abdominaux'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
      ),
    ];

    for (var exercise in defaultExercises) {
      await DatabaseService.instance.insertExercise(exercise);
    }
  }

  Future<void> startWorkout(String name, List<WorkoutExercise> exercises) async {
    _currentWorkout = Workout(
      id: _uuid.v4(),
      name: name,
      exercises: exercises,
      startedAt: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> completeWorkout() async {
    if (_currentWorkout == null) return;

    // Sauvegarder l'historique pour chaque exercice
    for (var workoutExercise in _currentWorkout!.exercises) {
      if (workoutExercise.isCompleted) {
        final history = WorkoutHistory(
          id: _uuid.v4(),
          exerciseId: workoutExercise.exercise.id,
          exerciseName: workoutExercise.exercise.name,
          sets: workoutExercise.sets.where((s) => s.completed).toList(),
          performedAt: DateTime.now(),
          totalVolume: workoutExercise.totalVolume,
        );
        
        // Sauvegarder dans la base de données
        // TODO: Implémenter la sauvegarde de l'historique
      }
    }

    _currentWorkout = null;
    notifyListeners();
  }

  void updateSet(String exerciseId, int setIndex, WorkoutSet updatedSet) {
    if (_currentWorkout == null) return;

    final exerciseIndex = _currentWorkout!.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex != -1) {
      _currentWorkout!.exercises[exerciseIndex].sets[setIndex] = updatedSet;
      notifyListeners();
    }
  }

  void completeSet(String exerciseId, int setIndex) {
    if (_currentWorkout == null) return;

    final exerciseIndex = _currentWorkout!.exercises.indexWhere((e) => e.id == exerciseId);
    if (exerciseIndex != -1) {
      final set = _currentWorkout!.exercises[exerciseIndex].sets[setIndex];
      _currentWorkout!.exercises[exerciseIndex].sets[setIndex] = set.copyWith(completed: true);
      notifyListeners();
    }
  }

  Future<List<WorkoutHistory>> getExerciseHistory(String exerciseId) async {
    return await DatabaseService.instance.getExerciseHistory(exerciseId, limit: 5);
  }

  List<Exercise> getExercisesByCategory(String category) {
    return _exercises.where((e) => e.category == category).toList();
  }

  Map<String, int> getMuscleGroupIntensity(Workout workout) {
    final Map<String, int> intensity = {};
    
    for (var exercise in workout.exercises) {
      for (var muscle in exercise.exercise.muscleGroups) {
        intensity[muscle] = (intensity[muscle] ?? 0) + exercise.sets.length;
      }
    }
    
    return intensity;
  }

  // Récupérer les meilleures performances pour un exercice
  Future<Map<String, dynamic>> getBestPerformance(String exerciseId) async {
    final history = await getExerciseHistory(exerciseId);
    
    if (history.isEmpty) {
      return {'maxWeight': 0.0, 'maxVolume': 0.0, 'maxReps': 0};
    }

    double maxWeight = 0;
    double maxVolume = 0;
    int maxReps = 0;

    for (var workout in history) {
      maxVolume = maxVolume > workout.totalVolume ? maxVolume : workout.totalVolume;
      
      for (var set in workout.sets) {
        maxWeight = maxWeight > set.weight ? maxWeight : set.weight;
        maxReps = maxReps > set.reps ? maxReps : set.reps;
      }
    }

    return {
      'maxWeight': maxWeight,
      'maxVolume': maxVolume,
      'maxReps': maxReps,
    };
  }
}
