import 'package:flutter/material.dart';
import 'device_list_tile.dart';

class DeviceList extends StatelessWidget {
  final List<String> devices;

  const DeviceList({
    super.key,
    required this.devices,
  });

  @override
  Widget build(BuildContext context) {
    if (devices.isEmpty) {
      return const Center(child: Text("No nearby devices"));
    }
    return ListView.builder(
      itemCount: devices.length,
      itemBuilder: (context, index) {
        return DeviceListTile(
          deviceName: devices[index],
          onTap: () {
            // TODO: Handle device tap (e.g., navigate to chat)
          },
        );
      },
    );
  }
}
