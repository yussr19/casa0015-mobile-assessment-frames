import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';

// main entry point - need to initialise firebase before anything runs
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const FramesApp());
}

class FramesApp extends StatelessWidget {
  const FramesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frames',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // going for a dark wood feel throughout the app
        primaryColor: const Color(0xFF2A1A08),
        scaffoldBackgroundColor: const Color(0xFF1A1208),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B4A10),
          brightness: Brightness.dark,
        ),
        fontFamily: 'Georgia',
      ),
      home: const SplashScreen(),
    );
  }
}