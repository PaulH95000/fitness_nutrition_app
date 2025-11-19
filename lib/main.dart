import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'providers/user_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/fitness_provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser les locales pour les dates en français
  await initializeDateFormatting('fr_FR', null);

  // Initialiser la base de données
  await DatabaseService.instance.database;

  runApp(const MyApp());
}

class MyAppInitializer extends StatefulWidget {
  final Widget child;

  const MyAppInitializer({super.key, required this.child});

  @override
  State<MyAppInitializer> createState() => _MyAppInitializerState();
}

class _MyAppInitializerState extends State<MyAppInitializer> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('🚀 App Initialization starting...');

    try {
      // Initialiser les aliments par défaut
      print('🚀 Initializing nutrition provider...');
      await context.read<NutritionProvider>().initializeDefaultFoods();

      // Initialiser les exercices par défaut
      print('🚀 Initializing fitness provider...');
      await context.read<FitnessProvider>().loadExercises();

      print('✅ App Initialization complete!');
    } catch (e, stack) {
      print('❌ App Initialization ERROR: $e');
      print('Stack: $stack');
    }

    setState(() {
      _isInitialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => FitnessProvider()),
      ],
      child: MaterialApp(
        title: 'Fitness & Nutrition',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MyAppInitializer(child: HomeScreen()),
      ),
    );
  }
}
