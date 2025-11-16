# 🏋️ Features Fitness & Nutrition App

## ✨ Nouvelles fonctionnalités (inspirées de MyFitnessPal & Hevy)

### 📱 Interface Nutrition (Style MyFitnessPal)

#### Vue principale améliorée
- **Date Selector** : Navigation facile entre les jours avec sélecteur de date intégré
- **Carte calories gradient** : Affichage visuel moderne avec objectif/consommé/restant
- **Graphiques circulaires de macros** : Visualisation des protéines, glucides et lipides en temps réel
- **Timeline de repas** : Organisation claire par type de repas (petit-déj, déjeuner, dîner, collations)
- **Color-coding** : Indicateurs visuels pour savoir si vous êtes dans vos objectifs

#### Rapport hebdomadaire
- **Graphique de calories sur 7 jours** : Bar chart montrant votre consommation quotidienne
- **Distribution des macros** : Pie chart montrant vos pourcentages moyens
- **Insights automatiques** : Analyse de vos habitudes alimentaires
- **Séries de réussite** : Tracking de vos streaks (jours consécutifs d'objectif atteint)

#### Ajout de repas amélioré
- **Support multi-dates** : Ajout de repas pour n'importe quel jour
- **Type de repas présélectionné** : Lors du clic depuis un repas spécifique
- **Scan de code-barres** : Déjà intégré pour scan rapide
- **Favoris et récents** : Accès rapide à vos aliments fréquents

### 💪 Interface Fitness (Style Hevy)

#### Graphiques de progression
- **Écran de progression par exercice** : Visualisation détaillée de vos performances
- **Graphiques multiples** : Volume, poids max, reps max
- **Sélecteur de métrique** : Choisissez ce que vous voulez visualiser
- **Historique détaillé** : Toutes vos séances passées pour un exercice

#### One Rep Max Calculator
- **Calculateur intégré** : Estimez votre 1RM basé sur n'importe quelle série
- **Formule : Poids × (1 + Reps / 30)**
- **Interface intuitive** : Résultat en temps réel

#### Plate Calculator (Calculateur de plaques)
- **Calcul automatique** : Sachez combien de plaques mettre de chaque côté
- **Support barres multiples** : Olympique (20kg), Femmes (15kg), EZ (10kg)
- **Visualisation** : Aperçu visuel de la barre avec les plaques
- **Code couleur des plaques** : Respect du standard olympique
  - 25kg : Bleu
  - 20kg : Jaune
  - 15kg : Vert
  - 10kg : Blanc
  - 5kg : Rouge
  - 2.5kg et moins : Gris

#### Muscle Heatmap
- **Visualisation moderne** : Cartes colorées par groupe musculaire
- **Vue face et dos** : Couverture complète du corps
- **Intensité visuelle** : 4 niveaux d'intensité (repos, léger, modéré, intense)
- **Comptage de séries** : Nombre de séries par muscle affiché

#### Statistiques avancées
- **Volume tracking** : Sets × Reps × Weight pour chaque séance
- **Performances maximales** : Max poids, max reps, volume total
- **Comparaison de séances** : Voir votre progression dans le temps

### 🎨 Design et UX

#### Couleurs et thèmes
- **Palette moderne** : Primaire (#6C63FF), Accent (#00D4AA), Success (#4CAF50)
- **Gradients** : Cartes avec dégradés subtils pour plus de profondeur
- **Shadows douces** : Élévation moderne et professionnelle
- **Icons cohérents** : Material Design icons partout

#### Components réutilisables
- **Cartes statistiques** : Design uniforme pour toutes les stats
- **Chips et tags** : Pour catégories, macros, etc.
- **Progress bars** : Linéaires et circulaires avec animations
- **Bottom sheets** : Pour sélections et options

### 📊 Graphiques et Visualisations

Utilisation de `fl_chart` pour :
- **LineChart** : Progression dans le temps
- **BarChart** : Calories quotidiennes
- **PieChart** : Distribution des macros
- Tous avec interactions et tooltips

### 🔧 Architecture technique

#### Providers mis à jour
```dart
NutritionProvider:
  - loadMealsForDate(DateTime) : Chargement pour une date spécifique
  - loadWeeklyData() : Données hebdomadaires

FitnessProvider:
  - getBestPerformance(exerciseId) : Meilleures perfs
  - savedWorkoutTemplates : Templates de séances
```

#### Nouveaux écrans
```
lib/screens/nutrition/
  ├── nutrition_screen_v2.dart (🆕 MyFitnessPal style)
  ├── weekly_report_screen.dart (🆕 Rapport hebdomadaire)

lib/screens/fitness/
  ├── exercise_progress_screen.dart (🆕 Graphiques de progression)
  ├── plate_calculator_screen.dart (🆕 Calculateur de plaques)
  ├── muscle_heatmap_widget.dart (🆕 Heatmap muscles)
  ├── workout_session_screen.dart (Mode suivi en temps réel)
  ├── saved_workouts_screen.dart (Gestion des séances)
  ├── create_workout_screen.dart (Création de séances)
  └── exercise_selector_screen.dart (Sélection avancée)
```

## 🚀 Comment utiliser

### Nutrition
1. Naviguez vers l'onglet **Nutrition**
2. Utilisez le sélecteur de date en haut
3. Cliquez sur un repas pour ajouter des aliments
4. Scannez un code-barres ou cherchez dans la base
5. Consultez le rapport hebdomadaire pour voir vos tendances

### Fitness
1. Créez une séance depuis l'onglet **Fitness**
2. Utilisez la recherche avancée avec filtres
3. Démarrez la séance pour le suivi en temps réel
4. Consultez vos progressions par exercice
5. Utilisez le plate calculator avant chaque série

## 📈 Prochaines améliorations suggérées

### Nutrition
- [ ] Copie de repas d'autres jours
- [ ] Meal scan avec photo (AI)
- [ ] Recettes personnalisées
- [ ] Export PDF du rapport

### Fitness
- [ ] Social features (partage de séances)
- [ ] Supersets et circuits
- [ ] Rest timer avec notifications
- [ ] Dark mode complet

## 🎯 Conformité aux standards

### MyFitnessPal
✅ Timeline de repas par jour
✅ Graphiques circulaires de macros
✅ Rapport hebdomadaire
✅ Color-coding des progrès
✅ Quick add (favoris/récents)

### Hevy
✅ Graphiques de progression
✅ One Rep Max calculator
✅ Volume tracking
✅ Muscle group heatmap
✅ Plate calculator
✅ Interface simple et intuitive
✅ Analytics dashboard

## 📱 Compatibilité

- iOS 12+
- Android 5.0+
- Flutter 3.0+
- Dart 3.0+

## 📦 Dépendances principales

```yaml
dependencies:
  fl_chart: ^0.65.0  # Graphiques
  provider: ^6.1.1    # State management
  intl: ^0.18.1       # Formatage dates
  google_fonts: ^6.1.0 # Typographie
```

---

**Dernière mise à jour** : Novembre 2025
**Version** : 2.0.0
