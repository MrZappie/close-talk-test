import 'package:flutter/material.dart';
import 'package:sample_app/core/nearby_state_storage.dart';
import 'package:sample_app/presentation/base_page.dart';
import 'package:sample_app/services/permissions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wait a bit to allow the UI to show
  Future.delayed(const Duration(milliseconds: 500), () async {
    await askPerms();
  });
  await NearbyStateStorage.clearNearbyState();
  await NearbyStateStorage.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BasePage());
  }
}
