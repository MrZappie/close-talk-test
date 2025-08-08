import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'chat_page.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';
import 'package:sample_app/services/nearby_services.dart';

class ChatHistoryItem {
  final String name;
  final bool wasAvailable;

  ChatHistoryItem({required this.name, required this.wasAvailable});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _lastUsernameUpdate;

  // UI is driven by ValueNotifiers; lists below are placeholders only for initial empty state
  final List<String> _currentDevices = const [];
  final List<ChatHistoryItem> _chatHistory = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(() {});
    _tabController.dispose();
    super.dispose();
  }

  void _navigateToChat(ChatUserModel user) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => ChatPage(user: user)));
  }

  void _showUsernameUpdateNotification(String oldName, String newName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$oldName updated their name to $newName'),
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color darkShadow = Color.lerp(AppColors.primary, Colors.black, 0.4)!;
    final Color lightShadow = Color.lerp(AppColors.primary, Colors.white, 0.2)!;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            tooltip: 'Refresh UI',
            icon: const Icon(Icons.sync),
            onPressed: () => NearbyServices().refreshUI(),
          ),
          IconButton(
            tooltip: 'Restart broadcast',
            icon: const Icon(Icons.refresh),
            onPressed: () => NearbyServices().restartBroadcast(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildNeumorphicTab(0, "Current", darkShadow, lightShadow)),
                const SizedBox(width: 8),
                Expanded(child: _buildNeumorphicTab(1, "History", darkShadow, lightShadow)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Current devices: from connectedEndpoints (actually connected users)
                ValueListenableBuilder<List<ChatUserModel>>(
                  valueListenable: connectedEndpoints,
                  builder: (context, connectedDevices, _) {
                    return _buildAnimatedListView(
                      itemCount: connectedDevices.length,
                      itemBuilder: (context, index) {
                        final user = connectedDevices[index];
                        return _buildWhiteListItem(
                          child: ListTile(
                            leading: const Icon(Icons.person, color: AppColors.accent, size: 28),
                            title: Text(user.userName, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                            subtitle: const Text('Connected - Ready to chat', style: TextStyle(color: Colors.green)),
                            trailing: _buildAvailabilityIndicator(true),
                          ),
                          onTap: () => _navigateToChat(user),
                        );
                      },
                    );
                  },
                ),
                // History: union of users present in sent/received message maps + currently available users
                ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
                  valueListenable: receivedMessages,
                  builder: (context, receivedMap, _) {
                    return ValueListenableBuilder<Map<ChatUserModel, List<MessageModel>>>(
                      valueListenable: sendMessages,
                      builder: (context, sentMap, __) {
                        return ValueListenableBuilder<List<ChatUserModel>>(
                          valueListenable: discoveredList,
                          builder: (context, discoveredUsers, ___) {
                            // Combine message history users + currently available users
                            final messageUsers = <ChatUserModel>{...receivedMap.keys, ...sentMap.keys};
                            final allUsers = <ChatUserModel>{...messageUsers, ...discoveredUsers};
                            final users = allUsers.toList();
                            
                            return _buildAnimatedListView(
                              itemCount: users.length,
                              itemBuilder: (context, index) {
                                final user = users[index];
                                final isAvailable = discoveredUsers.any((u) => u.id == user.id || u.endpointId == user.endpointId);
                                final isConnected = connectedEndpoints.value.any((u) => u.id == user.id || u.endpointId == user.endpointId);
                                final last = _lastMessageForUser(user, sentMap, receivedMap);
                                
                                return _buildWhiteListItem(
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isConnected ? Colors.green : AppColors.accent,
                                      foregroundColor: Colors.white,
                                      child: Icon(
                                        isConnected ? Icons.person : Icons.person_outline, 
                                        size: 20
                                      ),
                                    ),
                                    title: Text(user.userName, style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold)),
                                    subtitle: Text(
                                      isConnected ? 'Connected - Ready to chat' : 
                                      isAvailable ? 'Available nearby' : 
                                      last?.$1 ?? 'No messages yet',
                                      style: TextStyle(
                                        color: isConnected ? Colors.green : 
                                        isAvailable ? Colors.orange : Colors.grey
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildAvailabilityIndicator(isAvailable || isConnected),
                                        if (last != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4.0),
                                            child: Text(
                                              _formatTime(last.$2),
                                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  onTap: () => _navigateToChat(user),
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeumorphicTab(int index, String title, Color darkShadow, Color lightShadow) {
    final bool isSelected = _tabController.index == index;
    final Color pressedColor = Color.lerp(AppColors.primary, Colors.black, 0.15)!;

    return GestureDetector(
      onTap: () => _tabController.animateTo(index),
      child: AnimatedScale(
        scale: isSelected ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? pressedColor : AppColors.primary,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(color: darkShadow, offset: const Offset(1, 1), blurRadius: 2, spreadRadius: 0.5),
                    BoxShadow(color: lightShadow, offset: const Offset(-1, -1), blurRadius: 2, spreadRadius: 0.5),
                  ]
                : [
                    BoxShadow(color: darkShadow, offset: const Offset(4, 4), blurRadius: 10, spreadRadius: 1),
                    BoxShadow(color: lightShadow, offset: const Offset(-4, -4), blurRadius: 10, spreadRadius: 1),
                  ],
          ),
          child: Center(child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5))),
        ),
      ),
    );
  }

  Widget _buildWhiteListItem({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildAvailabilityIndicator(bool isAvailable) {
    final Color color = isAvailable ? Colors.green.shade400 : Colors.red.shade400;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [BoxShadow(color: color.withOpacity(0.7), blurRadius: 8.0, spreadRadius: 2.0)],
      ),
    );
  }

  Widget _buildAnimatedListView({required int itemCount, required Widget Function(BuildContext, int) itemBuilder}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _FadeInSlide(
          duration: Duration(milliseconds: 300 + (index * 50)),
          child: itemBuilder(context, index),
        );
      },
    );
  }

  /// Returns a tuple (lastMessageText, createdTime) for the user, or null
  (String, DateTime)? _lastMessageForUser(
    ChatUserModel user,
    Map<ChatUserModel, List<MessageModel>> sentMap,
    Map<ChatUserModel, List<MessageModel>> receivedMap,
  ) {
    final sent = sentMap[user] ?? const <MessageModel>[];
    final received = receivedMap[user] ?? const <MessageModel>[];
    if (sent.isEmpty && received.isEmpty) return null;
    final all = <MessageModel>[...sent, ...received]
      ..sort((a, b) => b.createdTime.compareTo(a.createdTime));
    final last = all.first;
    return (last.value, last.createdTime);
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _formatTime(DateTime dt) => "${_two(dt.hour)}:${_two(dt.minute)}";
}

class _FadeInSlide extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const _FadeInSlide({required this.child, this.duration = const Duration(milliseconds: 500)});

  @override
  State<_FadeInSlide> createState() => _FadeInSlideState();
}

class _FadeInSlideState extends State<_FadeInSlide> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}


