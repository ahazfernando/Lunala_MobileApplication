import 'package:flutter/material.dart';
import 'language_selection_screen.dart';
import 'home_screen.dart';
import '../services/firebase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _checkLoginSession();
  }

  Future<void> _checkLoginSession() async {
    // Wait for splash screen to show for at least 2 seconds
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;

    try {
      // Check if user has a saved login session
      final phoneNumber = await _firebaseService.getCurrentUserPhoneNumber();
      final customerId = await _firebaseService.getCurrentCustomerId();
      
      print('SplashScreen: Checking login session...');
      print('SplashScreen: Phone number: ${phoneNumber ?? "null"}');
      print('SplashScreen: Customer ID: ${customerId ?? "null"}');
      
      // If we have either phone number or customer ID, user is logged in
      if (phoneNumber != null || customerId != null) {
        print('SplashScreen: User is logged in, navigating to HomeScreen');
        // User is logged in, go directly to home screen
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        print('SplashScreen: No login session found, navigating to LanguageSelectionScreen');
        // No login session, go to language selection then login
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
          );
        }
      }
    } catch (e) {
      print('SplashScreen: Error checking login session: $e');
      // On error, default to language selection screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LanguageSelectionScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Text(
          'Keells',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}



