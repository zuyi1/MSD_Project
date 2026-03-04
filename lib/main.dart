import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase initialization failed: $e");
  }
  runApp(const FoodDiaryApp());
}

class FoodDiaryApp extends StatelessWidget {
  const FoodDiaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Diary App',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A5AE0),
          brightness: Brightness.light,
          primary: const Color(0xFF6A5AE0),
          secondary: const Color(0xFF3E5444),
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Georgia',
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
