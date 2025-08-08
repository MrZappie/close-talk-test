// lib/main.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart'; // 1. Import your splash screen
import 'widgets/live_background.dart';

void main() {
  runApp(const CloseTalkApp());
}

class CloseTalkApp extends StatelessWidget {
  const CloseTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: Colors.transparent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Colors.white,
        ),
      ),
      // 2. Set the SplashScreen as the home route
      home: const SplashScreen(),
    );
  }
}

// This is the main screen of your app after the splash screen.
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use a Stack to layer the live animation behind your screens
    return Stack(
      children: [
        // The LiveBackground is always at the bottom of the stack
        const LiveBackground(),
        
        // Your main scaffold sits on top of the animation
        Scaffold(
          body: _screens[_selectedIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            backgroundColor: AppColors.primary.withOpacity(0.8), // A subtle transparent background
            selectedItemColor: Colors.white,
            unselectedItemColor: AppColors.lightAccent,
            elevation: 0,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ],
    );
  }
}