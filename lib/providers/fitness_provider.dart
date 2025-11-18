import 'package:flutter/foundation.dart';
import '../models/workout_models.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class FitnessProvider extends ChangeNotifier {
  final _uuid = const Uuid();

  List<Exercise> _exercises = [];
  List<Exercise> _favoriteExercises = [];
  List<Workout> _savedWorkoutTemplates = [];  // Séances sauvegardées (templates)
  Workout? _currentWorkout; // Séance en cours
  WorkoutProgram? _activeProgram;

  bool _isLoading = false;

  List<Exercise> get exercises => _exercises;
  List<Exercise> get favoriteExercises => _favoriteExercises;
  List<Workout> get savedWorkoutTemplates => _savedWorkoutTemplates;
  Workout? get currentWorkout => _currentWorkout;
  WorkoutProgram? get activeProgram => _activeProgram;
  bool get isLoading => _isLoading;
  bool get hasActiveWorkout => _currentWorkout != null && _currentWorkout!.isInProgress;

  Future<void> loadExercises() async {
    print('🏋️ loadExercises: Starting...');
    _isLoading = true;
    notifyListeners();

    try {
      _exercises = await DatabaseService.instance.getAllExercises();
      print('🏋️ loadExercises: Loaded ${_exercises.length} exercises from database');

      // Si aucun exercice, créer une base d'exercices par défaut
      if (_exercises.isEmpty) {
        print('🏋️ loadExercises: No exercises found, creating default exercises...');
        await _createDefaultExercises();
        _exercises = await DatabaseService.instance.getAllExercises();
        print('🏋️ loadExercises: After creating defaults, we have ${_exercises.length} exercises');
      }

      _favoriteExercises = _exercises.where((e) => e.isFavorite).toList();
      print('🏋️ loadExercises: ${_favoriteExercises.length} favorite exercises');
    } catch (e, stack) {
      print('❌ Erreur lors du chargement des exercices: $e');
      print('Stack trace: $stack');
    }

    _isLoading = false;
    notifyListeners();
    print('🏋️ loadExercises: Complete with ${_exercises.length} total exercises');
  }

  Future<void> _createDefaultExercises() async {
    print('🏋️ _createDefaultExercises: Creating default exercises...');
    final defaultExercises = [
      // Pectoraux
      Exercise(
        id: _uuid.v4(),
        name: 'Développé couché',
        category: 'chest',
        muscleGroups: ['pectoraux', 'triceps', 'deltoïdes antérieurs'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Exercice de base pour les pectoraux avec barre',
        videoUrl: 'https://www.youtube.com/watch?v=rT7DgCr-3pg',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Développé incliné',
        category: 'chest',
        muscleGroups: ['pectoraux supérieurs', 'deltoïdes antérieurs'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
        description: 'Cible davantage le haut des pectoraux',
        videoUrl: 'https://www.youtube.com/watch?v=8iPEnn-ltC8',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Pompes',
        category: 'chest',
        muscleGroups: ['pectoraux', 'triceps'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Exercice au poids du corps polyvalent',
        videoUrl: 'https://www.youtube.com/watch?v=IODxDxX7oi4',
        isTimeBased: false,
      ),

      // Dos
      Exercise(
        id: _uuid.v4(),
        name: 'Tractions',
        category: 'back',
        muscleGroups: ['dorsaux', 'biceps', 'trapèzes'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Exercice de tirage au poids du corps très efficace',
        videoUrl: 'https://www.youtube.com/watch?v=eGo4IYlbE5g',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Rowing barre',
        category: 'back',
        muscleGroups: ['dorsaux', 'trapèzes', 'biceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Excellent pour l\'épaisseur du dos',
        videoUrl: 'https://www.youtube.com/watch?v=FWJR5Ve8bnQ',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Tirage vertical',
        category: 'back',
        muscleGroups: ['dorsaux', 'biceps'],
        equipment: 'cable',
        difficulty: 'beginner',
        description: 'Alternative aux tractions',
        videoUrl: 'https://www.youtube.com/watch?v=lueEJGjTuPQ',
        isTimeBased: false,
      ),

      // Jambes
      Exercise(
        id: _uuid.v4(),
        name: 'Squat',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers', 'ischio-jambiers'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Le roi des exercices pour les jambes',
        videoUrl: 'https://www.youtube.com/watch?v=ultWZbUMPL8',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Soulevé de terre',
        category: 'legs',
        muscleGroups: ['ischio-jambiers', 'fessiers', 'lombaires', 'trapèzes'],
        equipment: 'barbell',
        difficulty: 'advanced',
        description: 'Exercice complet pour tout le corps',
        videoUrl: 'https://www.youtube.com/watch?v=op9kVnSso6Q',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Presse à cuisses',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Alternative sûre au squat',
        videoUrl: 'https://www.youtube.com/watch?v=IZxyjW7MPJQ',
        isTimeBased: false,
      ),

      // Épaules
      Exercise(
        id: _uuid.v4(),
        name: 'Développé militaire',
        category: 'shoulders',
        muscleGroups: ['deltoïdes', 'triceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Exercice de base pour les épaules',
        videoUrl: 'https://www.youtube.com/watch?v=2yjwXTZQDDI',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Élévations latérales',
        category: 'shoulders',
        muscleGroups: ['deltoïdes latéraux'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole les deltoïdes latéraux',
        videoUrl: 'https://www.youtube.com/watch?v=3VcKaXpzqRo',
        isTimeBased: false,
      ),

      // Bras
      Exercise(
        id: _uuid.v4(),
        name: 'Curl biceps',
        category: 'arms',
        muscleGroups: ['biceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Exercice d\'isolation pour les biceps',
        videoUrl: 'https://www.youtube.com/watch?v=ykJmrZ5v0Oo',
        isTimeBased: false,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Extensions triceps',
        category: 'arms',
        muscleGroups: ['triceps'],
        equipment: 'cable',
        difficulty: 'beginner',
        description: 'Isole les triceps',
        videoUrl: 'https://www.youtube.com/watch?v=vB5OHsJ3EME',
        isTimeBased: false,
      ),

      // Core
      Exercise(
        id: _uuid.v4(),
        name: 'Planche',
        category: 'core',
        muscleGroups: ['abdominaux', 'lombaires'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Exercice de gainage statique',
        videoUrl: 'https://www.youtube.com/watch?v=ASdvN_XEl_c',
        isTimeBased: true, // Exercice temporisé !
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Crunchs',
        category: 'core',
        muscleGroups: ['abdominaux'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Exercice de base pour les abdominaux',
        videoUrl: 'https://www.youtube.com/watch?v=Xyd_fa5zoEU',
        isTimeBased: false,
      ),

      // ========== PECTORAUX (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Dips pectoraux',
        category: 'chest',
        muscleGroups: ['pectoraux', 'triceps', 'deltoïdes'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Penché en avant pour cibler les pectoraux',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Écartés haltères',
        category: 'chest',
        muscleGroups: ['pectoraux'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole les pectoraux',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Développé décliné',
        category: 'chest',
        muscleGroups: ['pectoraux inférieurs', 'triceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Cible le bas des pectoraux',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Pec deck',
        category: 'chest',
        muscleGroups: ['pectoraux'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Machine pour isolation pectoraux',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Pompes diamant',
        category: 'chest',
        muscleGroups: ['triceps', 'pectoraux'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Mains rapprochées pour les triceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Cable crossover',
        category: 'chest',
        muscleGroups: ['pectoraux'],
        equipment: 'cable',
        difficulty: 'intermediate',
        description: 'Exercice d\'isolation à la poulie',
      ),

      // ========== DOS (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Rowing haltère',
        category: 'back',
        muscleGroups: ['dorsaux', 'trapèzes'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
        description: 'Rowing unilatéral',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Tirage horizontal',
        category: 'back',
        muscleGroups: ['dorsaux', 'trapèzes', 'biceps'],
        equipment: 'cable',
        difficulty: 'beginner',
        description: 'Tirage assis à la poulie',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Pullover',
        category: 'back',
        muscleGroups: ['dorsaux', 'pectoraux'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
        description: 'Travaille l\'amplitude dorsale',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Shrugs',
        category: 'back',
        muscleGroups: ['trapèzes'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole les trapèzes supérieurs',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Rowing T-bar',
        category: 'back',
        muscleGroups: ['dorsaux', 'trapèzes'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Excellente variante du rowing',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Face pull',
        category: 'back',
        muscleGroups: ['trapèzes', 'deltoïdes postérieurs'],
        equipment: 'cable',
        difficulty: 'beginner',
        description: 'Excellent pour la posture',
      ),

      // ========== JAMBES (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Fentes',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Exercice unilatéral pour les jambes',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Bulgarian split squat',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
        description: 'Squat unilatéral pied arrière surélevé',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Leg curl',
        category: 'legs',
        muscleGroups: ['ischio-jambiers'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Isole les ischios',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Leg extension',
        category: 'legs',
        muscleGroups: ['quadriceps'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Isole les quadriceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Mollets debout',
        category: 'legs',
        muscleGroups: ['mollets'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Travaille les mollets',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Hip thrust',
        category: 'legs',
        muscleGroups: ['fessiers', 'ischio-jambiers'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Le meilleur exercice pour les fessiers',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Soulevé de terre jambes tendues',
        category: 'legs',
        muscleGroups: ['ischio-jambiers', 'fessiers', 'lombaires'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Variante ciblant les ischios',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Goblet squat',
        category: 'legs',
        muscleGroups: ['quadriceps', 'fessiers'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Squat avec haltère devant',
      ),

      // ========== ÉPAULES (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Développé Arnold',
        category: 'shoulders',
        muscleGroups: ['deltoïdes', 'triceps'],
        equipment: 'dumbbell',
        difficulty: 'intermediate',
        description: 'Variante popularisée par Arnold Schwarzenegger',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Élévations frontales',
        category: 'shoulders',
        muscleGroups: ['deltoïdes antérieurs'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole l\'avant des épaules',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Oiseau',
        category: 'shoulders',
        muscleGroups: ['deltoïdes postérieurs'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Travaille l\'arrière des épaules',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Rowing menton',
        category: 'shoulders',
        muscleGroups: ['deltoïdes', 'trapèzes'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Exercice complet épaules et trapèzes',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Développé haltères assis',
        category: 'shoulders',
        muscleGroups: ['deltoïdes', 'triceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Alternative au développé militaire',
      ),

      // ========== BRAS (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Curl marteau',
        category: 'arms',
        muscleGroups: ['biceps', 'avant-bras'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Travaille le brachial et les avant-bras',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Curl pupitre',
        category: 'arms',
        muscleGroups: ['biceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole complètement les biceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Dips triceps',
        category: 'arms',
        muscleGroups: ['triceps'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Buste droit pour cibler les triceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Barre au front',
        category: 'arms',
        muscleGroups: ['triceps'],
        equipment: 'barbell',
        difficulty: 'intermediate',
        description: 'Skull crushers pour les triceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Curl barre',
        category: 'arms',
        muscleGroups: ['biceps'],
        equipment: 'barbell',
        difficulty: 'beginner',
        description: 'Exercice de base pour les biceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Extensions overhead triceps',
        category: 'arms',
        muscleGroups: ['triceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Étire bien les triceps',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Curl concentration',
        category: 'arms',
        muscleGroups: ['biceps'],
        equipment: 'dumbbell',
        difficulty: 'beginner',
        description: 'Isole un biceps à la fois',
      ),

      // ========== CORE/ABDOS (suite) ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Mountain climbers',
        category: 'core',
        muscleGroups: ['abdominaux', 'cardio'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Exercice cardio et abdos',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Russian twists',
        category: 'core',
        muscleGroups: ['obliques', 'abdominaux'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Travaille les obliques',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Leg raises',
        category: 'core',
        muscleGroups: ['abdominaux inférieurs'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Cible le bas des abdos',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Ab wheel',
        category: 'core',
        muscleGroups: ['abdominaux', 'lombaires'],
        equipment: 'other',
        difficulty: 'advanced',
        description: 'Très intense pour les abdos',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Planche latérale',
        category: 'core',
        muscleGroups: ['obliques', 'abdominaux'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Gainage latéral pour les obliques',
        isTimeBased: true,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Sit-ups',
        category: 'core',
        muscleGroups: ['abdominaux'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Exercice classique pour les abdos',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Bicycle crunches',
        category: 'core',
        muscleGroups: ['abdominaux', 'obliques'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Travaille abdos et obliques simultanément',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Dead bug',
        category: 'core',
        muscleGroups: ['abdominaux', 'lombaires'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Excellent pour la stabilité du core',
      ),

      // ========== CARDIO ==========
      Exercise(
        id: _uuid.v4(),
        name: 'Course à pied',
        category: 'cardio',
        muscleGroups: ['jambes', 'cardio'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Cardio classique',
        isTimeBased: true,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Vélo',
        category: 'cardio',
        muscleGroups: ['jambes', 'cardio'],
        equipment: 'machine',
        difficulty: 'beginner',
        description: 'Faible impact sur les articulations',
        isTimeBased: true,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Rameur',
        category: 'cardio',
        muscleGroups: ['dos', 'jambes', 'cardio'],
        equipment: 'machine',
        difficulty: 'intermediate',
        description: 'Cardio complet corps entier',
        isTimeBased: true,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Burpees',
        category: 'cardio',
        muscleGroups: ['corps entier', 'cardio'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Exercice cardio très intense',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Jumping jacks',
        category: 'cardio',
        muscleGroups: ['corps entier', 'cardio'],
        equipment: 'bodyweight',
        difficulty: 'beginner',
        description: 'Échauffement et cardio léger',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Corde à sauter',
        category: 'cardio',
        muscleGroups: ['mollets', 'cardio'],
        equipment: 'other',
        difficulty: 'beginner',
        description: 'Excellent pour le cardio',
        isTimeBased: true,
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Box jumps',
        category: 'cardio',
        muscleGroups: ['jambes', 'cardio'],
        equipment: 'other',
        difficulty: 'intermediate',
        description: 'Exercice pliométrique',
      ),
      Exercise(
        id: _uuid.v4(),
        name: 'Sprints',
        category: 'cardio',
        muscleGroups: ['jambes', 'cardio'],
        equipment: 'bodyweight',
        difficulty: 'intermediate',
        description: 'Course haute intensité',
        isTimeBased: true,
      ),
    ];

    print('🏋️ _createDefaultExercises: Inserting ${defaultExercises.length} exercises into database...');
    for (var exercise in defaultExercises) {
      try {
        await DatabaseService.instance.insertExercise(exercise);
      } catch (e) {
        print('❌ Error inserting exercise "${exercise.name}": $e');
      }
    }
    print('🏋️ _createDefaultExercises: Finished inserting exercises');
  }

  // Gestion des séances templates (sauvegardées)

  void saveWorkout(Workout workout) {
    _savedWorkoutTemplates.add(workout);
    notifyListeners();
    // TODO: Sauvegarder dans la DB
  }

  void updateWorkout(Workout workout) {
    final index = _savedWorkoutTemplates.indexWhere((w) => w.id == workout.id);
    if (index != -1) {
      _savedWorkoutTemplates[index] = workout;
      notifyListeners();
      // TODO: Mettre à jour dans la DB
    }
  }

  void deleteWorkout(String workoutId) {
    _savedWorkoutTemplates.removeWhere((w) => w.id == workoutId);
    notifyListeners();
    // TODO: Supprimer de la DB
  }

  void duplicateWorkout(Workout workout) {
    final duplicated = Workout(
      id: _uuid.v4(),
      name: '${workout.name} (Copie)',
      defaultRestSeconds: workout.defaultRestSeconds,
      exercises: workout.exercises.map((e) {
        return WorkoutExercise(
          id: _uuid.v4(),
          exercise: e.exercise,
          sets: e.sets.map((s) {
            return WorkoutSet(
              id: _uuid.v4(),
              weight: s.weight,
              reps: s.reps,
              restSeconds: s.restSeconds,
            );
          }).toList(),
          order: e.order,
          notes: e.notes,
        );
      }).toList(),
    );
    _savedWorkoutTemplates.add(duplicated);
    notifyListeners();
  }

  // Démarrer une séance à partir d'un template
  Workout startWorkoutFromTemplate(Workout template) {
    final sessionWorkout = Workout(
      id: _uuid.v4(),
      name: template.name,
      defaultRestSeconds: template.defaultRestSeconds,
      exercises: template.exercises.map((e) {
        return WorkoutExercise(
          id: _uuid.v4(),
          exercise: e.exercise,
          sets: e.sets.map((s) {
            return WorkoutSet(
              id: _uuid.v4(),
              weight: s.weight,
              reps: s.reps,
              restSeconds: s.restSeconds,
              completed: false,
            );
          }).toList(),
          order: e.order,
          notes: e.notes,
        );
      }).toList(),
      startedAt: DateTime.now(),
    );

    _currentWorkout = sessionWorkout;
    notifyListeners();
    return sessionWorkout;
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
      if (workoutExercise.completedSets > 0) {
        final history = WorkoutHistory(
          id: _uuid.v4(),
          exerciseId: workoutExercise.exercise.id,
          exerciseName: workoutExercise.exercise.name,
          sets: workoutExercise.sets.where((s) => s.completed).toList(),
          performedAt: DateTime.now(),
          totalVolume: workoutExercise.totalVolume,
        );

        // Sauvegarder dans la base de données
        // TODO: Implémenter la sauvegarde de l'historique dans DatabaseService
        try {
          // await DatabaseService.instance.insertWorkoutHistory(history);
        } catch (e) {
          print('Erreur lors de la sauvegarde de l\'historique: $e');
        }
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

  // Toggle favori pour un exercice
  Future<void> toggleExerciseFavorite(String exerciseId) async {
    final index = _exercises.indexWhere((e) => e.id == exerciseId);
    if (index != -1) {
      final exercise = _exercises[index];
      final updated = Exercise(
        id: exercise.id,
        name: exercise.name,
        category: exercise.category,
        muscleGroups: exercise.muscleGroups,
        equipment: exercise.equipment,
        difficulty: exercise.difficulty,
        description: exercise.description,
        videoUrl: exercise.videoUrl,
        thumbnailUrl: exercise.thumbnailUrl,
        isFavorite: !exercise.isFavorite,
        isTimeBased: exercise.isTimeBased,
      );

      _exercises[index] = updated;
      _favoriteExercises = _exercises.where((e) => e.isFavorite).toList();
      notifyListeners();

      // TODO: Mettre à jour dans la DB
      try {
        await DatabaseService.instance.updateExercise(updated);
      } catch (e) {
        print('Erreur lors de la mise à jour du favori: $e');
      }
    }
  }

  Future<void> addCustomExercise(Exercise exercise) async {
    _exercises.add(exercise);
    notifyListeners();

    try {
      await DatabaseService.instance.insertExercise(exercise);
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'exercice personnalisé: $e');
    }
  }

  Future<List<WorkoutHistory>> getExerciseHistory(String exerciseId) async {
    try {
      return await DatabaseService.instance.getExerciseHistory(exerciseId, limit: 5);
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
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
