import 'dart:math';

/// Calculateurs de fitness et nutrition
class FitnessCalculators {
  /// Calcul du BMR (Basal Metabolic Rate) - Mifflin-St Jeor Equation
  /// Le métabolisme de base (calories brûlées au repos)
  static double calculateBMR({
    required double weight, // kg
    required double height, // cm
    required int age,
    required String gender, // 'male' ou 'female'
  }) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  /// Calcul du TDEE (Total Daily Energy Expenditure)
  /// Dépense énergétique totale quotidienne
  static double calculateTDEE({
    required double bmr,
    required String activityLevel,
  }) {
    final multipliers = {
      'sedentary': 1.2, // Peu ou pas d'exercice
      'light': 1.375, // Exercice léger 1-3 jours/semaine
      'moderate': 1.55, // Exercice modéré 3-5 jours/semaine
      'active': 1.725, // Exercice intense 6-7 jours/semaine
      'very_active': 1.9, // Exercice très intense, travail physique
    };

    return bmr * (multipliers[activityLevel] ?? 1.2);
  }

  /// Calcul des calories cibles selon l'objectif
  static double calculateTargetCalories({
    required double tdee,
    required String goal,
  }) {
    switch (goal) {
      case 'lose_weight':
        return tdee - 500; // Déficit de 500 kcal = ~0.5kg/semaine
      case 'gain_weight':
        return tdee + 500; // Surplus de 500 kcal = ~0.5kg/semaine
      case 'maintain':
      default:
        return tdee;
    }
  }

  /// Calcul du Body Fat % - Méthode US Navy
  /// Homme: tour de cou, taille (abdomen)
  /// Femme: tour de cou, taille, hanches
  static double calculateBodyFatNavy({
    required double height, // cm
    required double neck, // cm
    required double waist, // cm
    double? hips, // cm (requis pour femmes)
    required String gender,
  }) {
    if (gender.toLowerCase() == 'male') {
      // Formule homme: BF% = 495 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(height)) - 450
      final logWaistNeck = log(waist - neck) / ln10;
      final logHeight = log(height) / ln10;
      final bodyDensity = 1.0324 - 0.19077 * logWaistNeck + 0.15456 * logHeight;
      return (495 / bodyDensity - 450).clamp(3.0, 50.0);
    } else {
      // Formule femme
      if (hips == null) return 25.0; // Valeur par défaut si pas de hanches
      final logWaistHipsNeck = log(waist + hips - neck) / ln10;
      final logHeight = log(height) / ln10;
      final bodyDensity = 1.29579 - 0.35004 * logWaistHipsNeck + 0.22100 * logHeight;
      return (495 / bodyDensity - 450).clamp(10.0, 50.0);
    }
  }

  /// Calcul du BMI (Body Mass Index / IMC)
  static double calculateBMI({
    required double weight, // kg
    required double height, // cm
  }) {
    final heightMeters = height / 100;
    return weight / (heightMeters * heightMeters);
  }

  /// Interprétation du BMI
  static String interpretBMI(double bmi) {
    if (bmi < 18.5) return 'Sous-poids';
    if (bmi < 25) return 'Poids normal';
    if (bmi < 30) return 'Surpoids';
    if (bmi < 35) return 'Obésité modérée';
    if (bmi < 40) return 'Obésité sévère';
    return 'Obésité massive';
  }

  /// Calcul automatique des macros selon l'objectif
  /// Retourne {protein, carbs, fat} en grammes
  static Map<String, int> calculateMacros({
    required double targetCalories,
    required double weight, // kg
    required String goal,
  }) {
    int protein, carbs, fat;

    switch (goal) {
      case 'lose_weight':
        // Perte de poids: High protein, moderate carbs, low fat
        // 40% protéines, 30% glucides, 30% lipides
        protein = ((targetCalories * 0.40) / 4).round(); // 4 kcal/g
        carbs = ((targetCalories * 0.30) / 4).round();
        fat = ((targetCalories * 0.30) / 9).round(); // 9 kcal/g
        break;

      case 'gain_weight':
        // Prise de masse: High carbs, high protein, moderate fat
        // 30% protéines, 45% glucides, 25% lipides
        protein = ((targetCalories * 0.30) / 4).round();
        carbs = ((targetCalories * 0.45) / 4).round();
        fat = ((targetCalories * 0.25) / 9).round();
        break;

      case 'maintain':
      default:
        // Maintenance: Balanced
        // 30% protéines, 40% glucides, 30% lipides
        protein = ((targetCalories * 0.30) / 4).round();
        carbs = ((targetCalories * 0.40) / 4).round();
        fat = ((targetCalories * 0.30) / 9).round();
        break;
    }

    // S'assurer qu'on a au moins 1.6g protéine/kg de poids corporel
    final minProtein = (weight * 1.6).round();
    if (protein < minProtein) {
      protein = minProtein;
      // Réajuster les autres macros
      final proteinCals = protein * 4;
      final remainingCals = targetCalories - proteinCals;
      carbs = ((remainingCals * 0.55) / 4).round();
      fat = ((remainingCals * 0.45) / 9).round();
    }

    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  /// Validation des calories calculées selon macros
  /// Formule: (protein * 4) + (carbs * 4) + (fat * 9)
  static int calculateCaloriesFromMacros({
    required int protein,
    required int carbs,
    required int fat,
  }) {
    return (protein * 4) + (carbs * 4) + (fat * 9);
  }

  /// Calcul de la masse maigre (Lean Body Mass)
  static double calculateLeanBodyMass({
    required double weight, // kg
    required double bodyFatPercentage,
  }) {
    return weight * (1 - bodyFatPercentage / 100);
  }

  /// Calcul de la masse grasse
  static double calculateFatMass({
    required double weight, // kg
    required double bodyFatPercentage,
  }) {
    return weight * (bodyFatPercentage / 100);
  }

  /// Estimation du poids idéal selon la formule de Devine
  static double calculateIdealWeight({
    required double height, // cm
    required String gender,
  }) {
    final heightInches = height / 2.54;
    if (gender.toLowerCase() == 'male') {
      return 50 + 2.3 * (heightInches - 60);
    } else {
      return 45.5 + 2.3 * (heightInches - 60);
    }
  }
}
