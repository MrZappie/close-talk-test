import 'package:flutter/material.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/presentation/widgets/chat_user_tile.dart';
import 'package:sample_app/services/nearby_services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final service = NearbyServices();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          IconButton(
            onPressed: () {
              service.restartBroadcast();
            },
            icon: Icon(Icons.restore_rounded),
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: discoveredList,
        builder: (context, value, child) {
          return ListView.separated(
            itemBuilder: (context, index) {
              final user = value[index];
              return ChatUserTile(user: user);
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: value.length,
          );
        },
      ),
    );
  }
}
