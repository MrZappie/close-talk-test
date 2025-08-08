import 'package:flutter/material.dart';
import 'package:sample_app/ui/screens/main_shell.dart';
import 'package:sample_app/services/nearby_services.dart';

class BasePage extends StatefulWidget {
  const BasePage({super.key});

  @override
  State<BasePage> createState() => _BasePageState();
}

class _BasePageState extends State<BasePage> with WidgetsBindingObserver {
  final nearby = NearbyServices();

  @override
  void initState() {
    // TODO: implement initState
    nearby.startBroadcast();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the existing base with the new UI shell without overriding core logic
    return const MainShell();
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
