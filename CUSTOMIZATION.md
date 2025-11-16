# 🎨 Guide de Personnalisation et Extension

Ce guide vous aidera à personnaliser et étendre votre application Fitness & Nutrition.

## 🎨 Personnalisation du thème

### Modifier les couleurs principales

Éditez `lib/core/theme/app_theme.dart` :

```dart
// Couleurs principales
static const Color primaryColor = Color(0xFF6C63FF);  // Votre couleur principale
static const Color secondaryColor = Color(0xFFFF6584); // Couleur secondaire
static const Color accentColor = Color(0xFF00D4AA);    // Couleur d'accentuation
```

### Couleurs par catégorie

Pour les macronutriments :
```dart
static const Color caloriesColor = Color(0xFFFF6B6B);
static const Color proteinColor = Color(0xFF4ECDC4);
static const Color carbsColor = Color(0xFFFFE66D);
static const Color fatColor = Color(0xFFFF8B94);
```

Pour les groupes musculaires :
```dart
static const Color chestColor = Color(0xFFFF6B6B);
static const Color backColor = Color(0xFF4ECDC4);
// etc.
```

### Changer les polices

Modifiez dans `app_theme.dart` :
```dart
textTheme: GoogleFonts.robotoTextTheme() // Remplacez 'inter' par 'roboto', 'montserrat', etc.
```

## 🍔 Ajouter de nouveaux aliments

### Méthode 1 : Via l'interface utilisateur
1. Utilisez le scanner de code-barres
2. Ou recherchez via OpenFoodFacts

### Méthode 2 : Ajouter manuellement dans la base

```dart
final newFood = FoodItem(
  id: const Uuid().v4(),
  name: 'Mon aliment',
  caloriesPer100g: 250,
  proteinPer100g: 20,
  carbsPer100g: 30,
  fatPer100g: 10,
  servingSize: 100,
  category: 'protein',
);

await DatabaseService.instance.insertFoodItem(newFood);
```

### Méthode 3 : Import CSV

Créez un fichier `assets/foods.csv` :
```csv
name,calories,protein,carbs,fat,category
Poulet grillé,165,31,0,3.6,protein
Riz basmati,130,2.7,28,0.3,carbs
```

Puis créez une fonction d'import :
```dart
Future<void> importFoodsFromCSV(String csvPath) async {
  final csvString = await rootBundle.loadString(csvPath);
  final rows = const CsvToListConverter().convert(csvString);
  
  for (var i = 1; i < rows.length; i++) {
    final row = rows[i];
    final food = FoodItem(
      id: const Uuid().v4(),
      name: row[0],
      caloriesPer100g: row[1].toDouble(),
      proteinPer100g: row[2].toDouble(),
      carbsPer100g: row[3].toDouble(),
      fatPer100g: row[4].toDouble(),
      servingSize: 100,
      category: row[5],
    );
    await DatabaseService.instance.insertFoodItem(food);
  }
}
```

## 💪 Ajouter de nouveaux exercices

### Via le code

Éditez `lib/providers/fitness_provider.dart` dans `_createDefaultExercises()` :

```dart
Exercise(
  id: _uuid.v4(),
  name: 'Votre exercice',
  category: 'chest', // chest, back, legs, shoulders, arms, core
  muscleGroups: ['pectoraux', 'triceps'],
  equipment: 'barbell', // barbell, dumbbell, machine, bodyweight, cable
  difficulty: 'intermediate', // beginner, intermediate, advanced
  description: 'Description de l\'exercice',
),
```

### Catégories disponibles
- `chest` : Pectoraux
- `back` : Dos
- `legs` : Jambes
- `shoulders` : Épaules
- `arms` : Bras
- `core` : Abdominaux

## 🎯 Personnaliser l'algorithme de génération de repas

Éditez `lib/providers/nutrition_provider.dart` dans la fonction `generateMealPlan()` :

### Modifier la stratégie de sélection

```dart
// Exemple : Prioriser les aliments riches en protéines
selectedFoods.sort((a, b) => 
  (b.proteinPer100g / b.caloriesPer100g).compareTo(a.proteinPer100g / a.caloriesPer100g)
);

// Exemple : Prioriser les aliments faibles en calories
selectedFoods.sort((a, b) => 
  a.caloriesPer100g.compareTo(b.caloriesPer100g)
);
```

### Ajuster les quantités

```dart
// Modifier les limites de quantité
double quantity = (remainingCalories / food.caloriesPer100g) * 100;
quantity = quantity.clamp(30, 500); // Changez 50-300 en 30-500
```

### Critères de réussite

```dart
// Modifier la tolérance d'écart
bool get meetsTargets {
  final caloriesDiff = (totalCalories - targetCalories).abs();
  final proteinDiff = (totalProtein - targetProtein).abs();
  return caloriesDiff <= 100 && proteinDiff <= 20; // Changez les seuils
}
```

## 📊 Ajouter de nouveaux graphiques

### Exemple : Graphique d'évolution des macros

```dart
import 'package:fl_chart/fl_chart.dart';

Widget buildMacrosChart() {
  return LineChart(
    LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: proteinSpots,
          color: AppTheme.proteinColor,
        ),
        LineChartBarData(
          spots: carbsSpots,
          color: AppTheme.carbsColor,
        ),
        LineChartBarData(
          spots: fatSpots,
          color: AppTheme.fatColor,
        ),
      ],
    ),
  );
}
```

### Exemple : Graphique circulaire des calories par repas

```dart
PieChart(
  PieChartData(
    sections: [
      PieChartSectionData(
        value: breakfastCalories,
        title: 'Petit-déj',
        color: Colors.orange,
      ),
      PieChartSectionData(
        value: lunchCalories,
        title: 'Déjeuner',
        color: Colors.blue,
      ),
      // etc.
    ],
  ),
);
```

## 🎨 Améliorer la visualisation SVG du corps

### Ajouter plus de détails musculaires

Dans `lib/screens/fitness/body_visualization_widget.dart`, ajoutez de nouveaux groupes musculaires :

```dart
void _drawFrontBody(Canvas canvas, Size size, double centerX, double headRadius) {
  // ... code existant
  
  // Ajouter les avant-bras
  _drawMuscleGroup(
    canvas,
    'avant-bras',
    [
      Offset(centerX - headRadius * 1.8, waistY),
      Offset(centerX - headRadius * 1.6, waistY + headRadius * 2),
      Offset(centerX - headRadius * 1.9, waistY + headRadius * 2),
      Offset(centerX - headRadius * 2.1, waistY),
    ],
  );
}
```

### Personnaliser les couleurs d'intensité

```dart
Color fillColor = Colors.grey[300]!;
if (intensity > 0) {
  final baseColor = AppTheme.getMuscleGroupColor(muscleKey);
  // Modifiez la logique d'opacité
  final opacity = intensity > 5 ? 0.9 : (intensity / 5) * 0.5;
  fillColor = baseColor.withOpacity(opacity);
}
```

## 🔔 Ajouter des notifications

### 1. Installer le package

```yaml
dependencies:
  flutter_local_notifications: ^16.0.0
```

### 2. Créer un service de notifications

```dart
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }
  
  static Future<void> scheduleWorkoutReminder() async {
    await _notifications.zonedSchedule(
      0,
      'Rappel d\'entraînement',
      'Il est temps de faire votre séance !',
      // Planifiez l'heure
      tz.TZDateTime.now(tz.local).add(const Duration(hours: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'workout_channel',
          'Entraînements',
          importance: Importance.high,
        ),
      ),
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

## 📱 Ajouter de nouveaux écrans

### Exemple : Écran de statistiques

1. Créez le fichier `lib/screens/statistics/statistics_screen.dart` :

```dart
class StatisticsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: Consumer2<NutritionProvider, FitnessProvider>(
        builder: (context, nutrition, fitness, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Vos statistiques personnalisées
                _buildWeeklyCaloriesChart(),
                _buildMonthlyWorkoutsChart(),
                _buildProgressSummary(),
              ],
            ),
          );
        },
      ),
    );
  }
}
```

2. Ajoutez-le à la navigation :

```dart
// Dans home_screen.dart
final List<Widget> _screens = [
  const NutritionScreen(),
  const FitnessScreen(),
  const StatisticsScreen(), // Nouveau
  const ProfileScreen(),
];
```

## 🌐 Intégration avec d'autres APIs

### Exemple : Spoonacular API pour les recettes

```dart
class RecipeApiService {
  static const String _apiKey = 'VOTRE_CLE_API';
  static const String _baseUrl = 'https://api.spoonacular.com';
  
  Future<List<Recipe>> searchRecipes(String query) async {
    final url = Uri.parse('$_baseUrl/recipes/complexSearch?query=$query&apiKey=$_apiKey');
    final response = await http.get(url);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Parsez les recettes
    }
    return [];
  }
}
```

## 💾 Export et Import de données

### Export en JSON

```dart
Future<String> exportUserData() async {
  final profile = await DatabaseService.instance.getUserProfile();
  final meals = await DatabaseService.instance.getMealEntriesForDate(DateTime.now());
  
  final data = {
    'profile': profile?.toMap(),
    'meals': meals.map((m) => m.toMap()).toList(),
    'exported_at': DateTime.now().toIso8601String(),
  };
  
  return json.encode(data);
}
```

### Import depuis JSON

```dart
Future<void> importUserData(String jsonString) async {
  final data = json.decode(jsonString);
  
  if (data['profile'] != null) {
    final profile = UserProfile.fromMap(data['profile']);
    await DatabaseService.instance.insertUserProfile(profile);
  }
  
  // Import des repas, etc.
}
```

## 🎮 Gamification

### Ajouter un système de badges

```dart
class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  
  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.unlocked = false,
  });
}

// Exemples de badges
final achievements = [
  Achievement(
    id: 'first_workout',
    name: 'Première séance',
    description: 'Complétez votre première séance',
    icon: Icons.fitness_center,
  ),
  Achievement(
    id: 'week_streak',
    name: 'Semaine parfaite',
    description: 'Respectez vos objectifs 7 jours consécutifs',
    icon: Icons.local_fire_department,
  ),
];
```

## 🔐 Authentification et synchronisation cloud

### Firebase Auth & Firestore

1. Ajoutez Firebase à votre projet
2. Créez un service d'authentification :

```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  Future<User?> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }
  
  Future<void> syncData() async {
    final user = _auth.currentUser;
    if (user != null) {
      // Synchronisez vos données avec Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData);
    }
  }
}
```

## 📈 Analytics

### Ajouter Firebase Analytics

```dart
class AnalyticsService {
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  static Future<void> logMealAdded(String foodName) async {
    await _analytics.logEvent(
      name: 'meal_added',
      parameters: {'food_name': foodName},
    );
  }
  
  static Future<void> logWorkoutCompleted(int duration) async {
    await _analytics.logEvent(
      name: 'workout_completed',
      parameters: {'duration_minutes': duration},
    );
  }
}
```

---

**Bon développement ! 🚀**
