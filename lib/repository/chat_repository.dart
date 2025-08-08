import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:sample_app/models/message_model.dart';

class ChatRepository {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  BluetoothConnection? _connection;
  final _messagesController = StreamController<MessageModel>.broadcast();

  Stream<MessageModel> get messagesStream => _messagesController.stream;

  /// Enable Bluetooth
  Future<void> enableBluetooth() async {
    final state = await _bluetooth.state;
    if (state != BluetoothState.STATE_ON) {
      await _bluetooth.requestEnable();
    }
  }

  /// Discover nearby devices
  Future<List<BluetoothDevice>> discoverDevices() async {
    final devices = <BluetoothDevice>[];
    await for (var discovery in _bluetooth.startDiscovery()) {
      if (!devices.any((d) => d.address == discovery.device.address)) {
        devices.add(discovery.device);
      }
    }
    return devices;
  }

  /// Connect to a device
  Future<void> connectToDevice(String address) async {
    _connection = await BluetoothConnection.toAddress(address);
    print('Connected to $address');

    _connection!.input!
        .listen((data) {
          try {
            final msg = MessageModel.fromBytes(data);
            _messagesController.add(msg);
          } catch (e) {
            print('Error parsing message: $e');
          }
        })
        .onDone(() {
          print('Disconnected from device');
        });
  }

  /// Send a message
  void sendMessage(MessageModel message) {
    if (_connection != null && _connection!.isConnected) {
      _connection!.output.add(Uint8List.fromList(message.toBytes()));
      _connection!.output.allSent;
    } else {
      print('Not connected to any device.');
    }
  }

  /// Close connection
  Future<void> disconnect() async {
    await _connection?.close();
    _connection = null;
  }

  void dispose() {
    _messagesController.close();
    disconnect();
  }
}
