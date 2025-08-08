// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../main.dart'; // We'll navigate to MainScreen from here

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  // This function simulates app initialization.
  Future<void> _initializeApp() async {
    // Wait for 5 seconds to show the splash screen.
    await Future.delayed(const Duration(seconds: 5));

    // Navigate to the main screen.
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- Background color exactly matching GIF ---
      backgroundColor: const Color(0xFF201E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Your App Name
            const Text(
              "closeTalk",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Your specific GIF file
            Image.asset(
              'assets/loading1.gif',
              width: 120,
              height: 120,
            ),

            const SizedBox(height: 24),

            // A loading message
            Text(
              "Finding your circle...",
              style: TextStyle(
                fontSize: 16,
                color: AppColors.lightAccent.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
