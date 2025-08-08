import 'package:flutter/material.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';

class ChatHistorySpace extends StatelessWidget {
  final ChatUserModel user;

  const ChatHistorySpace({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
      valueListenable: receivedMessages,
      builder: (context, receivedMap, _) {
        return ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
          valueListenable: sendMessages,
          builder: (context, sendMap, _) {
            final r = receivedMap[user] ?? [];
            final s = sendMap[user] ?? [];

            // Combine and sort messages
            final combinedMessages = <MapEntry<MessageModel, bool>>[
              ...r.map((m) => MapEntry(m, true)),
              ...s.map((m) => MapEntry(m, false)),
            ]..sort((a, b) => a.key.createdTime.compareTo(b.key.createdTime));

            return ListView.separated(
              itemCount: combinedMessages.length,
              itemBuilder: (context, index) {
                final entry = combinedMessages[index];
                return Align(
                  alignment: entry.value
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 17,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: entry.value ? Colors.grey[300] : Colors.blue[200],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(entry.key.value),
                  ),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(height: 20),
            );
          },
        );
      },
    );
  }
}
