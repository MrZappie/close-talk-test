import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/core/hive_adapters.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/user_profile.dart';
import 'package:uuid/uuid.dart';
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

  // Hive init
  await Hive.initFlutter();
  Hive.registerAdapter(ChatUserModelAdapter());
  Hive.registerAdapter(MessageModelAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  await Hive.openBox<UserProfile>(kBoxProfile);
  await Hive.openBox<ChatUserModel>(kBoxUsers);
  await Hive.openBox<List>(kBoxMessagesSent);
  await Hive.openBox<List>(kBoxMessagesReceived);

  // Ensure a permanent unique id and profile exists at first launch
  final profileBox = Hive.box<UserProfile>(kBoxProfile);
  var me = profileBox.get('me');
  if (me == null) {
    final newId = const Uuid().v4();
    me = UserProfile(id: newId, userName: 'User');
    await profileBox.put('me', me);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BasePage());
  }
}
