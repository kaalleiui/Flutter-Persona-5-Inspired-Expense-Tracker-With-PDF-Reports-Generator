import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'models/expense.dart';
import 'models/category.dart';
import 'models/balance.dart';
import 'models/confidant.dart';
import 'models/income.dart';
import 'screens/splash_screen.dart';
import 'theme/persona_theme.dart';
import 'screens/home_screen.dart';

// Register Hive adapters
void _registerAdapters() {
  Hive.registerAdapter(ExpenseAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(BalanceAdapter());
  Hive.registerAdapter(ConfidantAdapter());
  Hive.registerAdapter(ConfidantSystemAdapter());
  Hive.registerAdapter(IncomeAdapter());
}

// Open all required Hive boxes
Future<void> _openHiveBoxes() async {
  await Hive.openBox<Expense>('expenses');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Balance>('balance');
  await Hive.openBox<ConfidantSystem>('confidant_system');
  await Hive.openBox<Income>('income');
  await Hive.openBox('settings');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: PersonaTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarDividerColor: PersonaTheme.primaryRed.withOpacity(0.2),
    ),
  );
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  _registerAdapters();
  
  // Open boxes
  await _openHiveBoxes();
  
  // Initialize default data if needed
  final confidantBox = Hive.box<ConfidantSystem>('confidant_system');
  if (confidantBox.isEmpty) {
    await confidantBox.add(ConfidantSystem.defaultSystem());
  }
  
  // Initialize categories if not exists
  final categoryBox = Hive.box<Category>('categories');
  if (categoryBox.isEmpty) {
    await _initializeCategories();
  }
  
  runApp(const PersonaExpenseApp());
}

Future<void> _initializeCategories() async {
  final categoryBox = Hive.box<Category>('categories');
  
  final defaultCategories = [
    Category(name: 'Makanan', color: PersonaTheme.primaryRed.value, icon: Icons.restaurant.codePoint),
    Category(name: 'Transportasi', color: PersonaTheme.accentGold.value, icon: Icons.directions_car.codePoint),
    Category(name: 'Belanja', color: PersonaTheme.darkRed.value, icon: Icons.shopping_bag.codePoint),
    Category(name: 'Hiburan', color: PersonaTheme.cardColor.value, icon: Icons.movie.codePoint),
    Category(name: 'Tagihan', color: PersonaTheme.primaryRed.value, icon: Icons.receipt.codePoint),
    Category(name: 'Kesehatan', color: PersonaTheme.accentGold.value, icon: Icons.health_and_safety.codePoint),
  ];
  
  for (var category in defaultCategories) {
    await categoryBox.add(category);
  }
}

class PersonaExpenseApp extends StatelessWidget {
  const PersonaExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    return MaterialApp(
      title: 'Count Your Boros',
      debugShowCheckedModeBanner: false,
      theme: PersonaTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}