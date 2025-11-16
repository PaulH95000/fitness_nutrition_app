# 🏋️ Fitness & Nutrition App

Une application Flutter complète pour le suivi de la nutrition et du fitness avec tracking des calories, planification de repas, et visualisation des groupes musculaires travaillés.

## ✨ Fonctionnalités

### 📊 Partie Nutrition
- ✅ Profil utilisateur avec objectifs personnalisés (poids, calories, macros)
- ✅ Suivi quotidien des calories et macronutriments (protéines, glucides, lipides)
- ✅ Recherche d'aliments via API OpenFoodFacts
- ✅ Scan de code-barres pour ajouter rapidement des aliments
- ✅ Gestion des aliments favoris et récents
- ✅ **Planificateur de repas intelligent** : génère automatiquement des repas selon vos objectifs
- ✅ Sélection d'aliments disponibles pour la génération de repas
- ✅ Décompte des calories restantes en temps réel
- ✅ Historique des repas par type (petit-déjeuner, déjeuner, dîner, collations)

### 💪 Partie Fitness
- ✅ Base de données d'exercices (pectoraux, dos, jambes, épaules, bras, abdos)
- ✅ Création et suivi de séances d'entraînement
- ✅ **Visualisation interactive SVG des muscles travaillés**====
- ✅ Système d'historique intelligent des performances
- ✅ Affichage des dernières performances lors d'un exercice
- ✅ Tracking des séries, poids et répétitions
- ✅ Progression visuelle de la séance en cours
- ✅ Calcul automatique du volume total

### 📈 Suivi et Analytics
- ✅ Graphiques d'évolution du poids
- ✅ Calcul automatique du BMI, BMR et TDEE
- ✅ Statistiques nutritionnelles détaillées
- ✅ Visualisation de l'intensité musculaire

## 🎨 Design

- Interface moderne avec Material Design 3
- Thème clair et sombre
- Animations fluides
- Design responsive
- Palette de couleurs cohérente pour chaque catégorie

## 🚀 Installation

### Prérequis
- Flutter SDK (>= 3.0.0)
- Dart SDK (>= 3.0.0)
- Android Studio / Xcode (pour émulation)

### Étapes

1. **Cloner le projet**
```bash
cd fitness_nutrition_app
```

2. **Installer les dépendances**
```bash
flutter pub get
```

3. **Lancer l'application**
```bash
flutter run
```

## 📱 Structure du projet

```
lib/
├── core/
│   └── theme/
│       └── app_theme.dart          # Thème et couleurs
├── models/
│   ├── user_profile.dart           # Modèle profil utilisateur
│   ├── food_item.dart              # Modèle aliment
│   ├── meal_entry.dart             # Modèle repas
│   └── workout_models.dart         # Modèles fitness
├── providers/
│   ├── user_provider.dart          # Gestion état utilisateur
│   ├── nutrition_provider.dart     # Gestion état nutrition
│   └── fitness_provider.dart       # Gestion état fitness
├── services/
│   ├── database_service.dart       # Service SQLite
│   └── food_api_service.dart       # Service API OpenFoodFacts
├── screens/
│   ├── home_screen.dart            # Navigation principale
│   ├── nutrition/
│   │   ├── nutrition_screen.dart   # Écran principal nutrition
│   │   ├── add_meal_screen.dart    # Ajout de repas
│   │   └── meal_planner_screen.dart # Planificateur de repas
│   ├── fitness/
│   │   ├── fitness_screen.dart     # Écran principal fitness
│   │   ├── workout_screen.dart     # Séance d'entraînement
│   │   └── body_visualization_widget.dart # Visualisation SVG
│   └── profile/
│       └── profile_screen.dart     # Profil utilisateur
└── main.dart                       # Point d'entrée
```

## 🔧 Technologies utilisées

### Frameworks & Libraries
- **Flutter** - Framework UI cross-platform
- **Provider** - Gestion d'état
- **SQLite (sqflite)** - Base de données locale
- **fl_chart** - Graphiques et visualisations
- **mobile_scanner** - Scan de code-barres
- **http/dio** - Requêtes API
- **flutter_svg** - Support SVG
- **google_fonts** - Polices personnalisées

### APIs
- **OpenFoodFacts API** - Base de données alimentaires mondiale

## 📖 Guide d'utilisation

### 1. Configuration initiale
1. Au premier lancement, créez votre profil
2. Renseignez vos informations (âge, poids, objectif)
3. L'app calcule automatiquement vos besoins caloriques

### 2. Suivi nutrition
1. **Ajouter un aliment** :
   - Cliquez sur le bouton "+"
   - Recherchez l'aliment ou scannez le code-barres
   - Sélectionnez la quantité
   - Choisissez le type de repas

2. **Planifier un repas** :
   - Allez dans le planificateur de repas
   - Sélectionnez vos aliments disponibles (favoris ou récents)
   - Cliquez sur "Générer"
   - L'app crée un repas optimal pour vos objectifs restants
   - Régénérez jusqu'à satisfaction
   - Enregistrez le plan

### 3. Suivi fitness
1. **Créer une séance** :
   - Cliquez sur "Nouvelle séance"
   - Sélectionnez vos exercices
   - Démarrez l'entraînement

2. **Pendant l'entraînement** :
   - Consultez vos dernières performances
   - Remplissez poids et répétitions
   - Marquez les séries comme complétées
   - Visualisez les muscles travaillés en temps réel

3. **Visualisation SVG** :
   - Les muscles travaillés s'affichent en couleur
   - L'intensité varie selon le nombre de séries
   - Vue de face et de dos

## 🎯 Fonctionnalités avancées

### Algorithme de génération de repas
L'algorithme optimise la sélection et les quantités d'aliments pour :
- Atteindre vos calories restantes (±50 kcal)
- Maximiser l'apport en protéines
- Respecter l'équilibre des macros
- Utiliser vos aliments préférés

### Calculs nutritionnels
- **BMR** (Basal Metabolic Rate) : Formule de Mifflin-St Jeor
- **TDEE** (Total Daily Energy Expenditure) : BMR × facteur d'activité
- **Objectifs caloriques** : Ajustés selon votre but (perte/maintien/prise)
- **Macros** : Répartition optimale selon vos objectifs

## 🔮 Améliorations futures

- [ ] Support multi-langues
- [ ] Synchronisation cloud
- [ ] Programmes d'entraînement préconçus
- [ ] Recettes complètes
- [ ] Partage de progression sur réseaux sociaux
- [ ] Rappels et notifications
- [ ] Mode sombre automatique
- [ ] Export des données en PDF
- [ ] Intégration avec wearables (Fitbit, Apple Watch)
- [ ] Coach virtuel IA

## 🐛 Dépannage

### Problème de build
```bash
flutter clean
flutter pub get
flutter run
```

### Problème de scanner
Assurez-vous d'avoir les permissions caméra dans :
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/Info.plist`

### Base de données
Pour réinitialiser la base de données :
```dart
await DatabaseService.instance.close();
// Supprimez le fichier fitness_nutrition.db
```

## 📄 License

Ce projet est sous licence MIT.

## 👥 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :
1. Fork le projet
2. Créer une branche (`git checkout -b feature/AmazingFeature`)
3. Commit vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Push vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrir une Pull Request

## 📧 Contact

Pour toute question ou suggestion, n'hésitez pas à ouvrir une issue sur GitHub.

---

**Bon entraînement et bon appétit ! 🏋️‍♂️🥗**
