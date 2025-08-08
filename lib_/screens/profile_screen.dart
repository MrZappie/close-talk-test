// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLocationBroadcasting = false;
  
  // --- State variables for editing the name ---
  bool _isEditing = false;
  late TextEditingController _nameController;
  String _currentName = "Your Name";
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _currentName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // --- Toggles editing mode ---
  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        // If canceling, revert any changes
        _nameController.text = _currentName;
      }
    });
  }

  // --- Saves the new name ---
  void _saveName() {
    setState(() {
      _currentName = _nameController.text;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Define shadow colors for the neumorphic effect
    final Color darkShadow = Color.lerp(AppColors.primary, Colors.black, 0.4)!;
    final Color lightShadow = Color.lerp(AppColors.primary, Colors.white, 0.2)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.accent,
                backgroundImage: AssetImage("assets/profile_placeholder.png"),
              ),
              const SizedBox(height: 12),
              
              // --- Use a condition to show either the name or the text field ---
              _isEditing
                  ? _buildNameEditor(darkShadow, lightShadow)
                  : Text(
                      _currentName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
              const SizedBox(height: 24),

              // --- Show either the "Edit" button or "Save"/"Cancel" buttons ---
              _isEditing
                  ? _buildSaveCancelButtons(darkShadow, lightShadow)
                  : _buildEditButton(darkShadow, lightShadow),
                  
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),

              // --- The rest of the profile items remain the same ---
              _buildWhiteListItem(
                child: SwitchListTile(
                  activeColor: AppColors.accent,
                  activeTrackColor: AppColors.mutedAccent,
                  title: const Text("Broadcast Location", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  subtitle: const Text("Allow others to see you nearby", style: TextStyle(color: Colors.grey)),
                  value: isLocationBroadcasting,
                  onChanged: (value) {
                    setState(() {
                      isLocationBroadcasting = value;
                    });
                  },
                ),
              ),
              _buildWhiteListItem(
                child: ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.primary),
                  title: const Text("Settings", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper widget for the "Edit Profile" button ---
  Widget _buildEditButton(Color darkShadow, Color lightShadow) {
    return _buildNeumorphicContainer(
      darkShadow: darkShadow,
      lightShadow: lightShadow,
      onTap: _toggleEditing,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.edit, size: 18, color: Colors.white),
            SizedBox(width: 8),
            Text("Edit Profile", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  // --- Helper widget for the name text field in edit mode ---
  Widget _buildNameEditor(Color darkShadow, Color lightShadow) {
    return _buildNeumorphicContainer(
      darkShadow: darkShadow,
      lightShadow: lightShadow,
      isPressed: true, // "Pressed in" effect
      child: TextField(
        controller: _nameController,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  // --- Helper widget for the "Save" and "Cancel" buttons ---
  Widget _buildSaveCancelButtons(Color darkShadow, Color lightShadow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cancel Button
        _buildNeumorphicContainer(
          darkShadow: darkShadow,
          lightShadow: lightShadow,
          onTap: _toggleEditing, // Reverts changes and exits edit mode
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text("Cancel", style: TextStyle(color: Colors.white70)),
          ),
        ),
        const SizedBox(width: 16),
        // Save Button
        _buildNeumorphicContainer(
          darkShadow: darkShadow,
          lightShadow: lightShadow,
          onTap: _saveName, // Saves the name and exits edit mode
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // --- Reusable helper for all neumorphic containers ---
  Widget _buildNeumorphicContainer({
    required Widget child,
    required Color darkShadow,
    required Color lightShadow,
    VoidCallback? onTap,
    bool isPressed = false,
  }) {
    final Color pressedColor = Color.lerp(AppColors.primary, Colors.black, 0.15)!;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isPressed ? pressedColor : AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isPressed
            ? [ // "Pressed in" shadows
                BoxShadow(color: darkShadow, offset: const Offset(1, 1), blurRadius: 2, spreadRadius: 0.5),
                BoxShadow(color: lightShadow, offset: const Offset(-1, -1), blurRadius: 2, spreadRadius: 0.5),
              ]
            : [ // "Raised" shadows
                BoxShadow(color: darkShadow, offset: const Offset(4, 4), blurRadius: 10, spreadRadius: 1),
                BoxShadow(color: lightShadow, offset: const Offset(-4, -4), blurRadius: 10, spreadRadius: 1),
              ],
        ),
        child: child,
      ),
    );
  }

  // Helper widget for the white list items
  Widget _buildWhiteListItem({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: child,
    );
  }
}