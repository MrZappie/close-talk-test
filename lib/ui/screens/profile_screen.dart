import 'package:flutter/material.dart';
import '../app_colors.dart';
import 'package:hive/hive.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/user_profile.dart';
import 'package:sample_app/services/nearby_services.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isLocationBroadcasting = true; // Start with broadcast enabled
  bool _isEditing = false;
  late TextEditingController _nameController;
  String _currentName = '';
  final NearbyServices _service = NearbyServices();

  @override
  void initState() {
    super.initState();
    final Box<UserProfile> profileBox = Hive.box<UserProfile>(kBoxProfile);
    _currentName = profileBox.get('me')?.userName ?? '';
    _nameController = TextEditingController(text: _currentName);
    // Initialize broadcast state based on service
    isLocationBroadcasting = _service.isAdvertising || _service.isDiscovering;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
      if (!_isEditing) {
        _nameController.text = _currentName;
      }
    });
  }

  Future<void> _saveName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;
    await _service.updateUserName(newName);
    setState(() {
      _currentName = newName;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color darkShadow = Color.lerp(AppColors.primary, Colors.black, 0.4)!;
    final Color lightShadow = Color.lerp(AppColors.primary, Colors.white, 0.2)!;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile'), centerTitle: true, elevation: 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.accent,
                backgroundImage: AssetImage('assets/profile_placeholder.png'),
              ),
              const SizedBox(height: 12),
              _isEditing
                  ? _buildNameEditor(darkShadow, lightShadow)
                  : Text(
                      _currentName.isEmpty ? 'Your Name' : _currentName,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
              const SizedBox(height: 24),
              _isEditing ? _buildSaveCancelButtons(darkShadow, lightShadow) : _buildEditButton(darkShadow, lightShadow),
              const SizedBox(height: 30),
              const Divider(color: Colors.white24),
              const SizedBox(height: 10),
              _buildWhiteListItem(
                child: SwitchListTile(
                  activeColor: AppColors.accent,
                  activeTrackColor: AppColors.mutedAccent,
                  title: const Text('Broadcast Location', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                  subtitle: const Text('Allow others to see you nearby', style: TextStyle(color: Colors.grey)),
                  value: isLocationBroadcasting,
                  onChanged: (value) async {
                    setState(() => isLocationBroadcasting = value);
                    if (value) {
                      await _service.startBroadcast();
                    } else {
                      await _service.stopBroadcast();
                    }
                  },
                ),
              ),
              _buildWhiteListItem(
                child: ListTile(
                  leading: const Icon(Icons.settings, color: AppColors.primary),
                  title: const Text('Settings', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
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

  Widget _buildEditButton(Color darkShadow, Color lightShadow) {
    return _buildNeumorphicContainer(
      darkShadow: darkShadow,
      lightShadow: lightShadow,
      onTap: _toggleEditing,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.edit, size: 18, color: Colors.white), SizedBox(width: 8), Text('Edit Profile', style: TextStyle(color: Colors.white))],
        ),
      ),
    );
  }

  Widget _buildNameEditor(Color darkShadow, Color lightShadow) {
    return _buildNeumorphicContainer(
      darkShadow: darkShadow,
      lightShadow: lightShadow,
      isPressed: true,
      child: TextField(
        controller: _nameController,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
        decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
      ),
    );
  }

  Widget _buildSaveCancelButtons(Color darkShadow, Color lightShadow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildNeumorphicContainer(
          darkShadow: darkShadow,
          lightShadow: lightShadow,
          onTap: _toggleEditing,
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
        ),
        const SizedBox(width: 16),
        _buildNeumorphicContainer(
          darkShadow: darkShadow,
          lightShadow: lightShadow,
          onTap: _saveName,
          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), child: Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        ),
      ],
    );
  }

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
              ? [
                  BoxShadow(color: darkShadow, offset: const Offset(1, 1), blurRadius: 2, spreadRadius: 0.5),
                  BoxShadow(color: lightShadow, offset: const Offset(-1, -1), blurRadius: 2, spreadRadius: 0.5),
                ]
              : [
                  BoxShadow(color: darkShadow, offset: const Offset(4, 4), blurRadius: 10, spreadRadius: 1),
                  BoxShadow(color: lightShadow, offset: const Offset(-4, -4), blurRadius: 10, spreadRadius: 1),
                ],
        ),
        child: child,
      ),
    );
  }

  Widget _buildWhiteListItem({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: child,
    );
  }
}


