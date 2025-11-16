class Exercise {
  final String id;
  final String name;
  final String category; // 'chest', 'back', 'legs', 'shoulders', 'arms', 'core', 'cardio'
  final List<String> muscleGroups; // Muscles spécifiques travaillés
  final String equipment; // 'barbell', 'dumbbell', 'machine', 'bodyweight', 'cable', etc.
  final String difficulty; // 'beginner', 'intermediate', 'advanced'
  final String? description;
  final String? videoUrl;
  final bool isFavorite;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
    required this.equipment,
    required this.difficulty,
    this.description,
    this.videoUrl,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'muscle_groups': muscleGroups.join(','),
      'equipment': equipment,
      'difficulty': difficulty,
      'description': description,
      'video_url': videoUrl,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      muscleGroups: (map['muscle_groups'] as String).split(','),
      equipment: map['equipment'],
      difficulty: map['difficulty'],
      description: map['description'],
      videoUrl: map['video_url'],
      isFavorite: map['is_favorite'] == 1,
    );
  }
}

class WorkoutSet {
  final String id;
  final double weight; // en kg
  final int reps;
  final int? restSeconds;
  final bool completed;
  final String? notes;

  WorkoutSet({
    required this.id,
    required this.weight,
    required this.reps,
    this.restSeconds,
    this.completed = false,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'weight': weight,
      'reps': reps,
      'rest_seconds': restSeconds,
      'completed': completed ? 1 : 0,
      'notes': notes,
    };
  }

  factory WorkoutSet.fromMap(Map<String, dynamic> map) {
    return WorkoutSet(
      id: map['id'],
      weight: map['weight'],
      reps: map['reps'],
      restSeconds: map['rest_seconds'],
      completed: map['completed'] == 1,
      notes: map['notes'],
    );
  }

  WorkoutSet copyWith({
    double? weight,
    int? reps,
    int? restSeconds,
    bool? completed,
    String? notes,
  }) {
    return WorkoutSet(
      id: id,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      completed: completed ?? this.completed,
      notes: notes ?? this.notes,
    );
  }
}

class WorkoutExercise {
  final String id;
  final Exercise exercise;
  final List<WorkoutSet> sets;
  final int order; // Ordre dans la séance
  final String? notes;

  WorkoutExercise({
    required this.id,
    required this.exercise,
    required this.sets,
    required this.order,
    this.notes,
  });

  bool get isCompleted => sets.every((set) => set.completed);
  
  int get completedSets => sets.where((set) => set.completed).length;
  
  double get totalVolume {
    return sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  }
}

class Workout {
  final String id;
  final String name;
  final List<WorkoutExercise> exercises;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int durationMinutes;
  final String? notes;

  Workout({
    required this.id,
    required this.name,
    required this.exercises,
    this.startedAt,
    this.completedAt,
    this.durationMinutes = 0,
    this.notes,
  });

  bool get isCompleted => completedAt != null;
  
  bool get isInProgress => startedAt != null && completedAt == null;
  
  int get totalSets => exercises.fold(0, (sum, ex) => sum + ex.sets.length);
  
  int get completedSets => exercises.fold(0, (sum, ex) => sum + ex.completedSets);
  
  double get progress => totalSets > 0 ? completedSets / totalSets : 0;
  
  List<String> get muscleGroupsWorked {
    final Set<String> muscles = {};
    for (var ex in exercises) {
      muscles.addAll(ex.exercise.muscleGroups);
    }
    return muscles.toList();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'notes': notes,
    };
  }
}

class WorkoutHistory {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final List<WorkoutSet> sets;
  final DateTime performedAt;
  final double totalVolume;

  WorkoutHistory({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.sets,
    required this.performedAt,
    required this.totalVolume,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exercise_id': exerciseId,
      'exercise_name': exerciseName,
      'performed_at': performedAt.toIso8601String(),
      'total_volume': totalVolume,
    };
  }

  factory WorkoutHistory.fromMap(Map<String, dynamic> map) {
    return WorkoutHistory(
      id: map['id'],
      exerciseId: map['exercise_id'],
      exerciseName: map['exercise_name'],
      sets: [], // Les sets seront chargés séparément
      performedAt: DateTime.parse(map['performed_at']),
      totalVolume: map['total_volume'],
    );
  }
}

class WorkoutProgram {
  final String id;
  final String name;
  final List<Workout> workouts;
  final String frequency; // 'daily', 'weekly', 'custom'
  final DateTime createdAt;
  final bool isActive;

  WorkoutProgram({
    required this.id,
    required this.name,
    required this.workouts,
    required this.frequency,
    DateTime? createdAt,
    this.isActive = false,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'frequency': frequency,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
    };
  }
}
