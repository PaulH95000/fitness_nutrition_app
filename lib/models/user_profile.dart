class UserProfile {
  final String id;
  final String name;
  final int age;
  final double currentWeight; // en kg
  final double targetWeight; // en kg
  final double height; // en cm
  final String gender; // 'male' ou 'female'
  final String activityLevel; // 'sedentary', 'light', 'moderate', 'active', 'very_active'
  final String goal; // 'lose_weight', 'maintain', 'gain_weight', 'gain_muscle'
  final DateTime createdAt;
  final DateTime updatedAt;

  // Objectifs nutritionnels
  final int dailyCaloriesTarget;
  final int proteinTarget; // en grammes
  final int carbsTarget; // en grammes
  final int fatTarget; // en grammes

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.dailyCaloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Calculer le BMR (Basal Metabolic Rate) avec la formule de Mifflin-St Jeor
  double get bmr {
    if (gender == 'male') {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * currentWeight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  // Calculer TDEE (Total Daily Energy Expenditure)
  double get tdee {
    final activityMultipliers = {
      'sedentary': 1.2,
      'light': 1.375,
      'moderate': 1.55,
      'active': 1.725,
      'very_active': 1.9,
    };
    return bmr * (activityMultipliers[activityLevel] ?? 1.2);
  }

  // Calculer le BMI
  double get bmi {
    final heightInMeters = height / 100;
    return currentWeight / (heightInMeters * heightInMeters);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'current_weight': currentWeight,
      'target_weight': targetWeight,
      'height': height,
      'gender': gender,
      'activity_level': activityLevel,
      'goal': goal,
      'daily_calories_target': dailyCaloriesTarget,
      'protein_target': proteinTarget,
      'carbs_target': carbsTarget,
      'fat_target': fatTarget,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      name: map['name'],
      age: map['age'],
      currentWeight: map['current_weight'],
      targetWeight: map['target_weight'],
      height: map['height'],
      gender: map['gender'],
      activityLevel: map['activity_level'],
      goal: map['goal'],
      dailyCaloriesTarget: map['daily_calories_target'],
      proteinTarget: map['protein_target'],
      carbsTarget: map['carbs_target'],
      fatTarget: map['fat_target'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  UserProfile copyWith({
    String? name,
    int? age,
    double? currentWeight,
    double? targetWeight,
    double? height,
    String? gender,
    String? activityLevel,
    String? goal,
    int? dailyCaloriesTarget,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
  }) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      age: age ?? this.age,
      currentWeight: currentWeight ?? this.currentWeight,
      targetWeight: targetWeight ?? this.targetWeight,
      height: height ?? this.height,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      dailyCaloriesTarget: dailyCaloriesTarget ?? this.dailyCaloriesTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
