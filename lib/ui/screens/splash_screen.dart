import 'package:flutter/material.dart';
import 'package:sample_app/presentation/base_page.dart';
import '../app_colors.dart';
import 'main_shell.dart';

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

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BasePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF201E1E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'CloseTalk',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            Image.asset('assets/loading1.gif', width: 120, height: 120),
            const SizedBox(height: 24),
            Text(
              'Finding your circle...',
              style: TextStyle(fontSize: 16, color: AppColors.lightAccent.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}


