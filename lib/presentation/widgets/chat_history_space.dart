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
            // Get messages for this specific user
            final received = receivedMap[user] ?? [];
            final sent = sendMap[user] ?? [];

            // Combine and sort messages
            final combined = <MessageModel>[...received, ...sent];
            combined.sort((a, b) => b.createdTime.compareTo(a.createdTime));

            return ListView.builder(
              reverse: true, // Newest messages at bottom
              itemCount: combined.length,
              itemBuilder: (context, index) {
                final message = combined[index];
                final isReceived = received.contains(message);

                return Align(
                  alignment: isReceived
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isReceived ? Colors.grey[300] : Colors.blue[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(message.value),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
