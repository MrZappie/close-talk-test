// lib/screens/chat_page.dart

import 'dart:ui'; // Still useful for other UI elements if needed
import 'package:flutter/material.dart';
import '../app_colors.dart';

class ChatPage extends StatefulWidget {
  final String contactName;

  const ChatPage({
    super.key,
    required this.contactName,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"sender": "other", "text": "Hey, how's it going?"},
    {"sender": "me", "text": "Pretty good, thanks! Cool to connect."},
    {"sender": "other", "text": "Yeah, for sure!"},
  ];

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add({
        "sender": "me",
        "text": _messageController.text.trim(),
      });
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    // The Scaffold background is kept white as requested
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        // The AppBar is restored to its solid color state
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              child: const Icon(Icons.person),
            ),
            const SizedBox(width: 12),
            Text(widget.contactName),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Chat Messages Area ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final bool isSentByMe = message['sender'] == 'me';

                return Align(
                  alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  // --- Use the new FauxGlassBubble widget ---
                  child: _FauxGlassBubble(
                    text: message['text']!,
                    isSentByMe: isSentByMe,
                  ),
                );
              },
            ),
          ),
          // --- Message Input Area (Restored to original style) ---
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Colors.grey.shade200,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: "Type a message...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Helper Widget for the Faux-Glassmorphic Bubble ---
class _FauxGlassBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;

  const _FauxGlassBubble({required this.text, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
    // Define gradient colors based on the user
    final gradient = isSentByMe
        ? LinearGradient(
            colors: [AppColors.accent, Color.lerp(AppColors.accent, AppColors.primary, 0.3)!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.grey.shade300, Colors.grey.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    final textColor = isSentByMe ? Colors.white : Colors.black87;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        gradient: gradient, // Apply the gradient to simulate glass
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5), // A subtle border enhances the effect
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          )
        ]
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor),
      ),
    );
  }
}