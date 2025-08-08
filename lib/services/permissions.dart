import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> askPerms() async {
  // Request location permission
  if (!await Permission.location.isGranted) {
    await Permission.location.request();
  }

  // Enable location service if not already enabled
  if (!await Location.instance.serviceEnabled()) {
    await Location.instance.requestService();
  }

  // Request external storage permission
  if (!await Permission.storage.isGranted) {
    await Permission.storage.request();
  }

  // Request Bluetooth-related permissions (Android 12+)
  await [
    Permission.bluetooth,
    Permission.bluetoothAdvertise,
    Permission.bluetoothConnect,
    Permission.bluetoothScan,
  ].request();

  // Request Nearby Wi-Fi Devices permission (Android 13+)
  await Permission.nearbyWifiDevices.request();
}
