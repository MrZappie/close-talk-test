// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'chat_page.dart';

// A simple model for chat history items
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

  final List<String> _currentDevices = ["Moonlight User", "Device Alpha", "Starlight Phone"];
  final List<ChatHistoryItem> _chatHistory = [
    ChatHistoryItem(name: "Celeste", wasAvailable: true),
    ChatHistoryItem(name: "Luna", wasAvailable: false),
    ChatHistoryItem(name: "Orion", wasAvailable: true),
  ];

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

  void _navigateToChat(String userName) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChatPage(contactName: userName),
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
        title: const Text("Home"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.primary,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Expanded(child: _buildNeumorphicTab(0, "Current", _currentDevices.length, darkShadow, lightShadow)),
                const SizedBox(width: 16),
                Expanded(child: _buildNeumorphicTab(1, "History", _chatHistory.length, darkShadow, lightShadow)),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- Current Devices Tab ---
                _buildAnimatedListView(
                  itemCount: _currentDevices.length,
                  itemBuilder: (context, index) {
                    final deviceName = _currentDevices[index];
                    return _buildWhiteListItem(
                      child: ListTile(
                        leading: const Icon(Icons.person_outline, color: AppColors.primary, size: 28),
                        title: Text(
                          deviceName,
                          style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'Available to chat',
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: _buildAvailabilityIndicator(true),
                      ),
                      onTap: () => _navigateToChat(deviceName),
                    );
                  },
                ),
                // --- History Tab ---
                _buildAnimatedListView(
                  itemCount: _chatHistory.length,
                  itemBuilder: (context, index) {
                    final historyItem = _chatHistory[index];
                    return _buildWhiteListItem(
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          child: Icon(Icons.person, size: 20),
                        ),
                        title: Text(
                          historyItem.name,
                          style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          "Last message...",
                          style: TextStyle(color: Colors.grey),
                        ),
                        trailing: _buildAvailabilityIndicator(historyItem.wasAvailable),
                      ),
                      onTap: () => _navigateToChat(historyItem.name),
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

  // Helper for neumorphic tabs
  Widget _buildNeumorphicTab(int index, String title, int count, Color darkShadow, Color lightShadow) {
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: isSelected ? AppColors.accent : Colors.white.withOpacity(0.15),
                child: Text(
                  count.toString(),
                  style: TextStyle(color: isSelected ? Colors.white : AppColors.lightAccent, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper for the white list items with a simple shadow ---
  Widget _buildWhiteListItem({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white, // Set background to white
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            // A single, soft shadow for a clean "card" look
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: child,
      ),
    );
  }

  // Helper for the glowing availability indicator
  Widget _buildAvailabilityIndicator(bool isAvailable) {
    final Color color = isAvailable ? Colors.green.shade400 : Colors.red.shade400;
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.7),
            blurRadius: 8.0,
            spreadRadius: 2.0,
          ),
        ],
      ),
    );
  }

  // Helper for an animated list view
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
}

// Simple Fade-in and Slide Animation Widget
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
    _slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
      child: SlideTransition(
        position: _slide,
        child: widget.child,
      ),
    );
  }
}