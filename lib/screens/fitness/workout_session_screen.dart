import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';

/// Écran de suivi en temps réel d'une séance d'entraînement
/// Avec timer, navigation entre exercices, pause, etc.
class WorkoutSessionScreen extends StatefulWidget {
  final Workout workout;

  const WorkoutSessionScreen({super.key, required this.workout});

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  int _currentExerciseIndex = 0;
  int _currentSetIndex = 0;
  bool _isResting = false;
  int _restSecondsRemaining = 0;
  Timer? _restTimer;
  final Stopwatch _workoutStopwatch = Stopwatch();
  Timer? _stopwatchTimer;

  @override
  void initState() {
    super.initState();
    _workoutStopwatch.start();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _stopwatchTimer?.cancel();
    _workoutStopwatch.stop();
    super.dispose();
  }

  WorkoutExercise get _currentExercise => widget.workout.exercises[_currentExerciseIndex];
  WorkoutSet get _currentSet => _currentExercise.sets[_currentSetIndex];

  bool get _isLastSet => _currentSetIndex >= _currentExercise.sets.length - 1;
  bool get _isLastExercise => _currentExerciseIndex >= widget.workout.exercises.length - 1;

  WorkoutExercise? get _nextExercise {
    if (_currentExerciseIndex < widget.workout.exercises.length - 1) {
      return widget.workout.exercises[_currentExerciseIndex + 1];
    }
    return null;
  }

  void _completeCurrentSet() {
    setState(() {
      // Marquer la série comme complétée
      _currentExercise.sets[_currentSetIndex] = _currentSet.copyWith(completed: true);

      // Démarrer le repos si configuré
      final restSeconds = _currentSet.restSeconds ?? 120; // 2min par défaut
      if (restSeconds > 0 && !_isLastSet) {
        _isResting = true;
        _restSecondsRemaining = restSeconds;
        _startRestTimer();
      } else {
        _moveToNextSet();
      }
    });
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_restSecondsRemaining > 0) {
          _restSecondsRemaining--;
        } else {
          _stopRest();
          _moveToNextSet();
        }
      });
    });
  }

  void _stopRest() {
    _restTimer?.cancel();
    _isResting = false;
    _restSecondsRemaining = 0;
  }

  void _skipRest() {
    _stopRest();
    _moveToNextSet();
  }

  void _adjustRestTime(int seconds) {
    setState(() {
      _restSecondsRemaining = (_restSecondsRemaining + seconds).clamp(0, 600);
      if (_restSecondsRemaining == 0) {
        _skipRest();
      }
    });
  }

  void _moveToNextSet() {
    setState(() {
      if (_isLastSet) {
        // Passer à l'exercice suivant
        if (!_isLastExercise) {
          _currentExerciseIndex++;
          _currentSetIndex = 0;
        } else {
          // Séance terminée !
          _showWorkoutCompleteDialog();
        }
      } else {
        _currentSetIndex++;
      }
    });
  }

  void _moveToPreviousSet() {
    setState(() {
      if (_currentSetIndex > 0) {
        _currentSetIndex--;
      } else if (_currentExerciseIndex > 0) {
        _currentExerciseIndex--;
        _currentSetIndex = widget.workout.exercises[_currentExerciseIndex].sets.length - 1;
      }
      _stopRest();
    });
  }

  void _showWorkoutCompleteDialog() {
    _workoutStopwatch.stop();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.successColor, size: 32),
            SizedBox(width: 12),
            Text('Bravo !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Séance terminée !', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Durée: ${_formatDuration(_workoutStopwatch.elapsed)}'),
            Text('Exercices: ${widget.workout.exercises.length}'),
            Text('Séries: ${widget.workout.totalSets}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await context.read<FitnessProvider>().completeWorkout();
              if (mounted) {
                Navigator.of(context).pop(); // Dialog
                Navigator.of(context).pop(); // WorkoutSessionScreen
              }
            },
            child: const Text('Terminer'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min ${seconds}s';
  }

  String _formatRestTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.workout.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Quitter la séance ?'),
                  content: const Text('Votre progression ne sera pas sauvegardée.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Continuer'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Dialog
                        Navigator.pop(context); // WorkoutSessionScreen
                      },
                      child: const Text('Quitter', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de progression
          _buildProgressBar(),

          // Chronomètre
          _buildStopwatch(),

          // Corps principal
          Expanded(
            child: _isResting ? _buildRestView() : _buildExerciseView(),
          ),

          // "Up Next" - Aperçu de la prochaine série ou du prochain exercice
          if (!_isResting && (!_isLastSet || _nextExercise != null))
            _buildUpNextCard(),

          // Contrôles
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = widget.workout.progress;
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppTheme.primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercice ${_currentExerciseIndex + 1}/${widget.workout.exercises.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Série ${_currentSetIndex + 1}/${_currentExercise.sets.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
            minHeight: 8,
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.workout.completedSets} / ${widget.workout.totalSets} séries',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStopwatch() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        _formatDuration(_workoutStopwatch.elapsed),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
      ),
    );
  }

  Widget _buildExerciseView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nom de l'exercice
          Card(
            color: AppTheme.getMuscleGroupColor(_currentExercise.exercise.category).withOpacity(0.2),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentExercise.exercise.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _currentExercise.exercise.muscleGroups.join(', '),
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Vidéo de l'exercice (si disponible)
          if (_currentExercise.exercise.videoUrl != null)
            Card(
              child: Container(
                height: 200,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 64, color: AppTheme.primaryColor),
                    const SizedBox(height: 8),
                    const Text('Voir la démonstration'),
                    const SizedBox(height: 4),
                    Text(
                      _currentExercise.exercise.videoUrl!,
                      style: const TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 20),

          // Informations de la série actuelle
          Card(
            color: AppTheme.accentColor.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Text('Série actuelle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildSetInfo('Poids', '${_currentSet.weight} kg'),
                      _buildSetInfo('Reps', '${_currentSet.reps}'),
                      if (_currentSet.restSeconds != null)
                        _buildSetInfo('Repos', '${_currentSet.restSeconds}s'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Historique de performance
          FutureBuilder<Map<String, dynamic>>(
            future: context.read<FitnessProvider>().getBestPerformance(_currentExercise.exercise.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!['maxWeight'] > 0) {
                final data = snapshot.data!;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.star, color: AppTheme.warningColor, size: 20),
                            SizedBox(width: 8),
                            Text('Meilleure performance', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('Max poids', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('${data['maxWeight']} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Max reps', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('${data['maxReps']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('Max volume', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                Text('${data['maxVolume'].toInt()} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSetInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildRestView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Icon(Icons.timelapse, size: 64, color: AppTheme.accentColor),
          const SizedBox(height: 16),
          const Text('Repos', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),

          // Timer circulaire
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: (_currentSet.restSeconds != null && _currentSet.restSeconds! > 0)
                        ? 1 - (_restSecondsRemaining / _currentSet.restSeconds!)
                        : 0,
                    strokeWidth: 10,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                  ),
                ),
                Text(
                  _formatRestTime(_restSecondsRemaining),
                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Contrôles de temps
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () => _adjustRestTime(-10),
                icon: const Icon(Icons.remove, size: 20),
                label: const Text('-10s'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _adjustRestTime(10),
                icon: const Icon(Icons.add, size: 20),
                label: const Text('+10s'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Modifier les détails de la série juste effectuée
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.edit, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      const Text('Série effectuée', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Poids (kg)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: _currentSet.weight.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              onChanged: (value) {
                                final weight = double.tryParse(value);
                                if (weight != null) {
                                  setState(() {
                                    _currentExercise.sets[_currentSetIndex] =
                                      _currentSet.copyWith(weight: weight);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Reps', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                            const SizedBox(height: 4),
                            TextFormField(
                              initialValue: _currentSet.reps.toString(),
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                isDense: true,
                                contentPadding: EdgeInsets.all(12),
                              ),
                              onChanged: (value) {
                                final reps = int.tryParse(value);
                                if (reps != null) {
                                  setState(() {
                                    _currentExercise.sets[_currentSetIndex] =
                                      _currentSet.copyWith(reps: reps);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildUpNextCard() {
    // Si on n'est pas à la dernière série, afficher la prochaine série
    if (!_isLastSet) {
      final nextSetNumber = _currentSetIndex + 2; // +2 car index commence à 0 et on veut la suivante
      final totalSets = _currentExercise.sets.length;
      final nextSet = _currentExercise.sets[_currentSetIndex + 1];

      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.1),
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_forward, size: 16, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Prochaine série: $nextSetNumber/$totalSets',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNextSetInfo('Poids', '${nextSet.weight} kg'),
                _buildNextSetInfo('Reps', '${nextSet.reps}'),
                if (nextSet.restSeconds != null)
                  _buildNextSetInfo('Repos', '${nextSet.restSeconds}s'),
              ],
            ),
          ],
        ),
      );
    }

    // Sinon, afficher le prochain exercice s'il existe
    if (_nextExercise != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.grey[300]!)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Prochain exercice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.getMuscleGroupColor(_nextExercise!.exercise.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center,
                    color: AppTheme.getMuscleGroupColor(_nextExercise!.exercise.category),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_nextExercise!.exercise.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        '${_nextExercise!.sets.length} séries',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNextSetInfo(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentExerciseIndex > 0 || _currentSetIndex > 0)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isResting ? null : _moveToPreviousSet,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
              ),
            ),
          if (_currentExerciseIndex > 0 || _currentSetIndex > 0)
            const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isResting ? _skipRest : _completeCurrentSet,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isResting ? AppTheme.accentColor : AppTheme.successColor,
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: Text(
                _isResting ? 'Terminer le repos' : 'Série terminée',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
