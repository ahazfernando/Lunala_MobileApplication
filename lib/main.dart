import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const KeellsApp());
}

class KeellsApp extends StatelessWidget {
  const KeellsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keells',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        primaryColor: const Color(0xFF00BF63),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.instrumentSansTextTheme(),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}



