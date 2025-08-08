import 'package:flutter/material.dart';
import 'package:sample_app/presentation/home_page.dart';
import 'package:sample_app/presentation/profile_page.dart';
import 'package:sample_app/services/nearby_services.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with WidgetsBindingObserver {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [HomePage(), ProfilePage()];

  final nearby = NearbyServices();

  @override
  void initState() {
    // TODO: implement initState
    nearby.startBroadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.red,
        currentIndex: _selectedIndex,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    nearby.stopBroadcast();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      nearby.startBroadcast();
    } else if (state == AppLifecycleState.resumed) {
      nearby.stopBroadcast();
    }
  }
}
