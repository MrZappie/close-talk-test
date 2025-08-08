import 'package:flutter/material.dart';
import '../models/chat_model.dart';

class ChatHistoryTile extends StatelessWidget {
  final ChatModel chat;

  const ChatHistoryTile({super.key, required this.chat});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.chat, color: Colors.indigo),
        title: Text(chat.deviceName),
        subtitle: Text(chat.lastMessage),
        onTap: () {
          // TODO: Open chat screen
        },
      ),
    );
  }
}
