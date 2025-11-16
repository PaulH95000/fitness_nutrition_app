import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  final _uuid = const Uuid();
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;
  bool get hasProfile => _userProfile != null;

  Future<void> loadUserProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _userProfile = await DatabaseService.instance.getUserProfile();
    } catch (e) {
      print('Erreur lors du chargement du profil: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createUserProfile({
    required String name,
    required int age,
    required double currentWeight,
    required double targetWeight,
    required double height,
    required String gender,
    required String activityLevel,
    required String goal,
  }) async {
    // Calculer les objectifs nutritionnels basés sur le TDEE
    final tempProfile = UserProfile(
      id: _uuid.v4(),
      name: name,
      age: age,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      dailyCaloriesTarget: 2000, // Temporaire
      proteinTarget: 150,
      carbsTarget: 200,
      fatTarget: 65,
    );

    // Ajuster les calories selon l'objectif
    int caloriesTarget = tempProfile.tdee.round();
    if (goal == 'lose_weight') {
      caloriesTarget -= 500; // Déficit de 500 cal
    } else if (goal == 'gain_weight' || goal == 'gain_muscle') {
      caloriesTarget += 300; // Surplus de 300 cal
    }

    // Calculer les macros (40% protéines, 30% glucides, 30% lipides pour perte de poids)
    int proteinTarget = ((caloriesTarget * 0.30) / 4).round(); // 1g protéine = 4 cal
    int carbsTarget = ((caloriesTarget * 0.40) / 4).round(); // 1g glucides = 4 cal
    int fatTarget = ((caloriesTarget * 0.30) / 9).round(); // 1g lipides = 9 cal

    _userProfile = UserProfile(
      id: tempProfile.id,
      name: name,
      age: age,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      dailyCaloriesTarget: caloriesTarget,
      proteinTarget: proteinTarget,
      carbsTarget: carbsTarget,
      fatTarget: fatTarget,
    );

    await DatabaseService.instance.insertUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> updateUserProfile({
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
  }) async {
    if (_userProfile == null) return;

    _userProfile = _userProfile!.copyWith(
      name: name,
      age: age,
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      height: height,
      gender: gender,
      activityLevel: activityLevel,
      goal: goal,
      dailyCaloriesTarget: dailyCaloriesTarget,
      proteinTarget: proteinTarget,
      carbsTarget: carbsTarget,
      fatTarget: fatTarget,
    );

    await DatabaseService.instance.updateUserProfile(_userProfile!);
    notifyListeners();
  }

  Future<void> updateWeight(double newWeight) async {
    if (_userProfile == null) return;

    // Enregistrer dans l'historique
    await DatabaseService.instance.insertWeightEntry(
      _uuid.v4(),
      newWeight,
      DateTime.now(),
    );

    // Mettre à jour le profil
    await updateUserProfile(currentWeight: newWeight);
  }

  Future<List<Map<String, dynamic>>> getWeightHistory() async {
    return await DatabaseService.instance.getWeightHistory(limit: 30);
  }
}
