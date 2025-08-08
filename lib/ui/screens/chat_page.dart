import 'package:flutter/material.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';
import 'package:sample_app/services/nearby_services.dart';
import '../app_colors.dart';

class ChatPage extends StatefulWidget {
  final ChatUserModel user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final NearbyServices _service = NearbyServices();
  bool _wasConnected = false;

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _service.sendChatMessage(
      MessageModel(value: text, createdTime: DateTime.now()),
      widget.user,
    );
    _messageController.clear();
  }

  void _connectToUser() {
    _service.connectToUser(widget.user);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connecting to ${widget.user.userName}...'),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Listen for connection changes
    connectedEndpoints.addListener(_onConnectionChanged);
  }

  @override
  void dispose() {
    connectedEndpoints.removeListener(_onConnectionChanged);
    super.dispose();
  }

  void _onConnectionChanged() {
    final isConnected = connectedEndpoints.value.any((u) => u.id == widget.user.id || u.endpointId == widget.user.endpointId);
    if (isConnected && !_wasConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Connected to ${widget.user.userName}!'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
    _wasConnected = isConnected;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Row(children: [
          ValueListenableBuilder<List<ChatUserModel>>(
            valueListenable: connectedEndpoints,
            builder: (context, connected, _) {
              final isConnected = connected.any((u) => u.id == widget.user.id || u.endpointId == widget.user.endpointId);
              return CircleAvatar(
                backgroundColor: isConnected ? Colors.green : AppColors.accent,
                foregroundColor: Colors.white,
                child: Icon(isConnected ? Icons.person : Icons.person_outline),
              );
            },
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.user.userName),
              ValueListenableBuilder<List<ChatUserModel>>(
                valueListenable: connectedEndpoints,
                builder: (context, connected, _) {
                  final isConnected = connected.any((u) => u.id == widget.user.id || u.endpointId == widget.user.endpointId);
                  return Text(
                    isConnected ? 'Connected' : 'Not connected',
                    style: TextStyle(
                      fontSize: 12,
                      color: isConnected ? Colors.green : Colors.grey,
                    ),
                  );
                },
              ),
            ],
          ),
        ]),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Column(children: [
        Expanded(
          child: ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
            valueListenable: receivedMessages,
            builder: (context, receivedMap, _) {
              return ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
                valueListenable: sendMessages,
                builder: (context, sendMap, __) {
                  final received = receivedMap[widget.user] ?? const <MessageModel>[];
                  final sent = sendMap[widget.user] ?? const <MessageModel>[];
                  final combined = <MessageModel>[...received, ...sent]
                    ..sort((a, b) => a.createdTime.compareTo(b.createdTime));

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: combined.length,
                    itemBuilder: (context, index) {
                      final message = combined[index];
                      final isSentByMe = sent.contains(message);
                      return Align(
                        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: _FauxGlassBubble(text: message.value, isSentByMe: isSentByMe),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: Colors.grey.shade200,
          child: Row(children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder<List<ChatUserModel>>(
              valueListenable: connectedEndpoints,
              builder: (context, connected, _) {
                final isConnected = connected.any((u) => u.id == widget.user.id || u.endpointId == widget.user.endpointId);
                return IconButton(
                  icon: Icon(isConnected ? Icons.send : Icons.wifi),
                  tooltip: isConnected ? 'Send' : 'Connect',
                  onPressed: isConnected ? _sendMessage : _connectToUser,
                  style: IconButton.styleFrom(
                    backgroundColor: isConnected ? AppColors.primary : Colors.orange,
                    foregroundColor: Colors.white
                  ),
                );
              },
            ),
          ]),
        ),
      ]),
    );
  }
}

class _FauxGlassBubble extends StatelessWidget {
  final String text;
  final bool isSentByMe;
  const _FauxGlassBubble({required this.text, required this.isSentByMe});

  @override
  Widget build(BuildContext context) {
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
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))],
      ),
      child: Text(text, style: TextStyle(color: textColor)),
    );
  }
}


