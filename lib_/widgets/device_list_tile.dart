// lib/widgets/device_list_tile.dart
import 'package:flutter/material.dart';

class DeviceListTile extends StatelessWidget {
  final String deviceName;
  final VoidCallback onTap;

  const DeviceListTile({
    super.key,
    required this.deviceName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.devices, color: Colors.indigo),
      title: Text(deviceName),
      trailing: const Icon(Icons.chat, color: Colors.grey),
      onTap: onTap,
    );
  }
}
