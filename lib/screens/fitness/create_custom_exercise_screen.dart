import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/fitness_provider.dart';
import '../../models/workout_models.dart';
import '../../core/theme/app_theme.dart';

/// Écran pour créer un exercice personnalisé
class CreateCustomExerciseScreen extends StatefulWidget {
  const CreateCustomExerciseScreen({super.key});

  @override
  State<CreateCustomExerciseScreen> createState() => _CreateCustomExerciseScreenState();
}

class _CreateCustomExerciseScreenState extends State<CreateCustomExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uuid = const Uuid();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();

  String _selectedCategory = 'chest';
  String _selectedEquipment = 'barbell';
  String _selectedDifficulty = 'intermediate';
  List<String> _selectedMuscleGroups = [];
  bool _isTimeBased = false;

  final List<Map<String, dynamic>> _categories = [
    {'id': 'chest', 'name': 'Pectoraux', 'icon': Icons.accessibility_new},
    {'id': 'back', 'name': 'Dos', 'icon': Icons.accessible_forward},
    {'id': 'legs', 'name': 'Jambes', 'icon': Icons.directions_run},
    {'id': 'shoulders', 'name': 'Épaules', 'icon': Icons.hardware},
    {'id': 'arms', 'name': 'Bras', 'icon': Icons.sports_martial_arts},
    {'id': 'core', 'name': 'Abdos/Core', 'icon': Icons.whatshot},
    {'id': 'cardio', 'name': 'Cardio', 'icon': Icons.favorite},
  ];

  final List<String> _muscleGroupOptions = [
    'Pectoraux', 'Deltoïdes', 'Biceps', 'Triceps', 'Avant-bras',
    'Trapèzes', 'Dorsaux', 'Lombaires',
    'Abdos', 'Obliques',
    'Quadriceps', 'Ischio-jambiers', 'Fessiers', 'Mollets',
  ];

  final List<Map<String, String>> _equipmentOptions = [
    {'id': 'barbell', 'name': 'Barre'},
    {'id': 'dumbbell', 'name': 'Haltères'},
    {'id': 'machine', 'name': 'Machine'},
    {'id': 'bodyweight', 'name': 'Poids du corps'},
    {'id': 'cable', 'name': 'Poulie'},
    {'id': 'kettlebell', 'name': 'Kettlebell'},
    {'id': 'resistance_band', 'name': 'Élastique'},
    {'id': 'other', 'name': 'Autre'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    super.dispose();
  }

  void _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedMuscleGroups.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez sélectionner au moins un groupe musculaire')),
      );
      return;
    }

    final exercise = Exercise(
      id: _uuid.v4(),
      name: _nameController.text,
      category: _selectedCategory,
      muscleGroups: _selectedMuscleGroups,
      equipment: _selectedEquipment,
      difficulty: _selectedDifficulty,
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      videoUrl: _videoUrlController.text.isEmpty ? null : _videoUrlController.text,
      isTimeBased: _isTimeBased,
    );

    try {
      await context.read<FitnessProvider>().addCustomExercise(exercise);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Exercice créé avec succès !'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        Navigator.pop(context, exercise);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Créer un exercice',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: _saveExercise,
            icon: const Icon(Icons.check),
            label: const Text('Enregistrer'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nom de l'exercice
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'exercice *',
                  hintText: 'Ex: Développé couché',
                  prefixIcon: Icon(Icons.fitness_center),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Le nom est requis';
                  }
                  return null;
                },
              ),
            ),

            const SizedBox(height: 16),

            // Catégorie
            const Text(
              'Catégorie *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return FilterChip(
                  avatar: Icon(
                    cat['icon'] as IconData,
                    size: 18,
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                  ),
                  label: Text(cat['name'] as String),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat['id'] as String);
                    }
                  },
                  selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                  checkmarkColor: AppTheme.primaryColor,
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Groupes musculaires
            const Text(
              'Groupes musculaires *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _muscleGroupOptions.map((muscle) {
                  final isSelected = _selectedMuscleGroups.contains(muscle);
                  return FilterChip(
                    label: Text(muscle),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedMuscleGroups.add(muscle);
                        } else {
                          _selectedMuscleGroups.remove(muscle);
                        }
                      });
                    },
                    selectedColor: AppTheme.accentColor.withOpacity(0.2),
                    checkmarkColor: AppTheme.accentColor,
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // Équipement
            const Text(
              'Équipement *',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                value: _selectedEquipment,
                decoration: const InputDecoration(border: InputBorder.none),
                items: _equipmentOptions.map((equip) {
                  return DropdownMenuItem(
                    value: equip['id'],
                    child: Text(equip['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedEquipment = value);
                  }
                },
              ),
            ),

            const SizedBox(height: 16),

            // Difficulté
            const Text(
              'Difficulté',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildDifficultyChip('Débutant', 'beginner'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDifficultyChip('Intermédiaire', 'intermediate'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDifficultyChip('Avancé', 'advanced'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Type d'exercice
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: SwitchListTile(
                title: const Text('Exercice temporisé'),
                subtitle: const Text('Ex: Planche, gainage (au lieu de reps)'),
                value: _isTimeBased,
                onChanged: (value) {
                  setState(() => _isTimeBased = value);
                },
                activeColor: AppTheme.primaryColor,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description (optionnel)',
                  hintText: 'Instructions d\'exécution...',
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Lien vidéo
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Lien vidéo YouTube (optionnel)',
                  hintText: 'https://youtube.com/...',
                  prefixIcon: Icon(Icons.video_library),
                  border: InputBorder.none,
                ),
                keyboardType: TextInputType.url,
              ),
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(String label, String value) {
    final isSelected = _selectedDifficulty == value;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedDifficulty = value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
