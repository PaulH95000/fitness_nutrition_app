# 📋 Structure Complète du Projet

## 📁 Organisation des fichiers

### Configuration
```
fitness_nutrition_app/
├── pubspec.yaml                    # Dépendances et configuration Flutter
├── README.md                       # Documentation principale
└── CUSTOMIZATION.md               # Guide de personnalisation
```

### Code source (lib/)

#### 🎨 Core (Fondations)
```
lib/core/theme/
└── app_theme.dart                 # Thème, couleurs, typographie
```

#### 📊 Models (Modèles de données)
```
lib/models/
├── user_profile.dart              # Profil utilisateur avec calculs BMR/TDEE
├── food_item.dart                 # Aliments et valeurs nutritionnelles
├── meal_entry.dart                # Repas consommés et plans de repas
└── workout_models.dart            # Exercices, séances, historique
```

#### 🔄 Providers (Gestion d'état)
```
lib/providers/
├── user_provider.dart             # État profil et objectifs
├── nutrition_provider.dart        # État nutrition et repas
└── fitness_provider.dart          # État fitness et entraînements
```

#### 💾 Services (Logique métier)
```
lib/services/
├── database_service.dart          # SQLite - CRUD toutes les entités
└── food_api_service.dart          # API OpenFoodFacts
```

#### 🖼️ Screens (Interfaces utilisateur)

**Navigation principale**
```
lib/screens/
└── home_screen.dart               # Navigation bottom bar (3 onglets)
```

**Module Nutrition**
```
lib/screens/nutrition/
├── nutrition_screen.dart          # Dashboard nutrition quotidien
├── add_meal_screen.dart           # Ajout d'aliments (recherche + scan)
└── meal_planner_screen.dart       # Génération automatique de repas
```

**Module Fitness**
```
lib/screens/fitness/
├── fitness_screen.dart            # Dashboard fitness + liste exercices
├── workout_screen.dart            # Séance en cours avec historique
└── body_visualization_widget.dart # Visualisation SVG muscles
```

**Module Profil**
```
lib/screens/profile/
└── profile_screen.dart            # Profil, stats, évolution poids
```

#### 🚀 Point d'entrée
```
lib/
└── main.dart                      # Configuration app + providers
```

---

## 🎯 Fonctionnalités par fichier

### user_profile.dart
- ✅ Stockage profil (âge, poids, taille, objectifs)
- ✅ Calcul BMR (formule Mifflin-St Jeor)
- ✅ Calcul TDEE (selon niveau d'activité)
- ✅ Calcul BMI
- ✅ Objectifs nutritionnels automatiques

### food_item.dart
- ✅ Informations nutritionnelles complètes
- ✅ Calcul dynamique selon quantité
- ✅ Support code-barres
- ✅ Système favoris et usage récent
- ✅ Catégorisation automatique

### meal_entry.dart
- ✅ Enregistrement repas avec timestamp
- ✅ Calcul totaux quotidiens
- ✅ Filtrage par type de repas
- ✅ Plans de repas générés

### workout_models.dart
- ✅ Base d'exercices complète
- ✅ Tracking séries/poids/reps
- ✅ Historique performances
- ✅ Calcul volume total
- ✅ Progression temps réel

### database_service.dart
- ✅ 10 tables SQLite
- ✅ Index optimisés
- ✅ CRUD complet
- ✅ Migrations automatiques
- ✅ Requêtes optimisées

### food_api_service.dart
- ✅ Recherche OpenFoodFacts
- ✅ Scan code-barres
- ✅ Parsing intelligent
- ✅ Catégorisation auto

### nutrition_provider.dart
- ✅ État repas du jour
- ✅ Recherche + scan
- ✅ Favoris + récents
- ✅ **Générateur de repas intelligent**
- ✅ Calculs macros temps réel

### fitness_provider.dart
- ✅ Gestion séances actives
- ✅ Historique exercices
- ✅ Tracking progression
- ✅ Calcul intensité musculaire
- ✅ Exercices par défaut

### nutrition_screen.dart
- ✅ Dashboard calories circulaire
- ✅ Graphes macros
- ✅ Liste repas par type
- ✅ Statistiques temps réel
- ✅ Refresh pull-to-refresh

### add_meal_screen.dart
- ✅ Recherche aliments
- ✅ Scanner code-barres
- ✅ Sélection type repas
- ✅ Ajustement quantité
- ✅ Aperçu nutritionnel

### meal_planner_screen.dart
- ✅ Sélection aliments disponibles
- ✅ Affichage objectifs restants
- ✅ **Génération optimisée**
- ✅ Régénération aléatoire
- ✅ Enregistrement plan

### fitness_screen.dart
- ✅ Carte séance en cours
- ✅ Exercices par catégorie
- ✅ Visualisation muscles
- ✅ Liste exercices
- ✅ Historique performances

### workout_screen.dart
- ✅ Sélection exercices
- ✅ Tracking séries temps réel
- ✅ **Affichage historique**
- ✅ Barre progression
- ✅ Complétion séance

### body_visualization_widget.dart
- ✅ **Dessin SVG personnalisé**
- ✅ Vue face + dos
- ✅ Coloration intensité
- ✅ 15+ groupes musculaires
- ✅ Légende dynamique

### profile_screen.dart
- ✅ Création profil
- ✅ Statistiques complètes
- ✅ Graphe évolution poids
- ✅ Objectifs nutritionnels
- ✅ Mise à jour poids

### app_theme.dart
- ✅ Material Design 3
- ✅ Thème clair/sombre
- ✅ Couleurs par catégorie
- ✅ Google Fonts (Inter)
- ✅ Components personnalisés

---

## 📊 Statistiques du projet

- **Fichiers Dart**: 19
- **Lignes de code**: ~5000+
- **Models**: 4
- **Providers**: 3
- **Services**: 2
- **Screens**: 9
- **Widgets personnalisés**: 10+

---

## 🔧 Dépendances principales

### UI/UX
- flutter_svg: SVG support
- google_fonts: Polices
- fl_chart: Graphiques
- animations: Transitions

### State Management
- provider: Gestion d'état

### Data & Storage
- sqflite: Base SQLite
- shared_preferences: Préférences
- path: Gestion chemins

### Network
- http: Requêtes HTTP
- dio: Client HTTP avancé

### Features
- mobile_scanner: Code-barres
- image_picker: Photos
- intl: Internationalisation

### Utils
- uuid: IDs uniques
- shimmer: Animations chargement

---

## 🎯 Points forts de l'architecture

### 1. Clean Architecture
- Séparation claire des responsabilités
- Models → Providers → Services → UI
- Testable et maintenable

### 2. Provider Pattern
- État réactif
- Pas de duplication
- Performance optimisée

### 3. Base de données robuste
- 10 tables relationnelles
- Index optimisés
- CRUD complet

### 4. API Integration
- OpenFoodFacts (700k+ produits)
- Gestion erreurs
- Fallback local

### 5. UX soignée
- Material Design 3
- Animations fluides
- Feedback utilisateur
- Loading states

---

## 🚀 Prochaines étapes recommandées

1. **Tests unitaires** : Ajouter tests pour providers et services
2. **Tests d'intégration** : Tester les flows complets
3. **CI/CD** : GitHub Actions pour build automatique
4. **Analytics** : Tracking usage et performances
5. **Crash reporting** : Firebase Crashlytics
6. **A/B Testing** : Optimisation UI/UX
7. **Internationalization** : Support multi-langues
8. **Accessibility** : Support lecteurs d'écran

---

**Projet créé avec ❤️ pour Flutter**
