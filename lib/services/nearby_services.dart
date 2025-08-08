import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:hive/hive.dart';
import 'package:nearby_connections/nearby_connections.dart';
import 'package:sample_app/core/constants.dart';
import 'package:sample_app/core/nearby_state_storage.dart';
import 'package:sample_app/core/values.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';
import 'package:sample_app/models/user_profile.dart';

class NearbyServices {
  static const String _messageType = 'message';

  // State tracking
  bool _isAdvertising = false;
  bool _isDiscovering = false;
  String _userName = 'User';
  String? _myId; // permanent unique id stored in profile
  final Map<String, ChatUserModel> _connectedUsers = {};
  final Map<String, ConnectionInfo> _connectionInfoMap = {};
  final Set<String> _pendingConnections = {};
  static const Duration _proximityCheckInterval = Duration(seconds: 5);
  static const int _maxConnectionAttempts = 2; // Fail if can't connect quickly
  final Map<String, int> _connectionAttempts = {};
  Timer? _proximityTimer;
  final Map<String, int> _connectionStability = {};
  Timer? _connectionMonitorTimer;
  static const Duration _connectionCheckInterval = Duration(seconds: 3);
  static const int _maxStabilityThreshold =
      3; // Allowed consecutive weak signals

  /// Start both advertising and discovery
  Future<void> startBroadcast() async {
    try {
      if (_isAdvertising || _isDiscovering) return;
      // Load username from Hive profile, fallback if missing
      final Box<UserProfile> profileBox = Hive.box<UserProfile>(kBoxProfile);
      final UserProfile? me = profileBox.get('me');
      if (me != null) {
        _userName = me.userName;
        _myId = me.id;
      }
      await hydrateFromStorage();
      await _startAdvertising();
      await _startDiscovery();

      print('Broadcast started as $_userName');
    } catch (e) {
      print('Start broadcast error: $e');
      rethrow;
    }
  }

  /// Restart broadcast with current settings
  Future<void> restartBroadcast() async {
    await stopBroadcast();
    await Future.delayed(const Duration(milliseconds: 500));
    await Nearby().stopAllEndpoints();
    _pendingConnections.clear();
    discoveredList.value = [];
    connectedUsers.clear();
    _connectionInfoMap.clear();
    connectedEndpoints.value = [];
    await startBroadcast();
  }

  /// Stop all Nearby activities
  Future<void> stopBroadcast() async {
    try {
      if (_isAdvertising) {
        await Nearby().stopAdvertising();
        _isAdvertising = false;
        NearbyStateStorage.setIsAdvertising(false);
      }

      if (_isDiscovering) {
        await Nearby().stopDiscovery();
        _isDiscovering = false;
        NearbyStateStorage.setIsDiscovering(false);
      }

      _pendingConnections.clear();

      _proximityTimer?.cancel();
      _proximityTimer = null;
      print('Broadcast stopped');
    } catch (e) {
      print('Stop broadcast error: $e');
      rethrow;
    }
  }

  /// Update username and restart if needed
  Future<void> updateUserName(String newName) async {
    _userName = newName;
    // Persist to Hive profile
    final Box<UserProfile> profileBox = Hive.box<UserProfile>(kBoxProfile);
    final UserProfile? me = profileBox.get('me');
    if (me == null) {
      // Generate a simple id if not present; use random or time-based
      final generatedId = DateTime.now().millisecondsSinceEpoch.toString();
      await profileBox.put('me', UserProfile(id: generatedId, userName: newName));
    } else {
      await profileBox.put('me', me.copyWith(userName: newName));
    }
    await restartBroadcast();
  }

  /// Hydrate UI state from Hive storage (users, messages)
  Future<void> hydrateFromStorage() async {
    final usersBox = Hive.box<ChatUserModel>(kBoxUsers);
    final sentBox = Hive.box<List>(kBoxMessagesSent);
    final receivedBox = Hive.box<List>(kBoxMessagesReceived);

    // Load users into discovered list (represents known peers)
    final users = usersBox.values.toList();
    discoveredList.value = users;

    // Build message maps
    final Map<ChatUserModel, List<MessageModel>> hydratedSent = {};
    final Map<ChatUserModel, List<MessageModel>> hydratedReceived = {};

    for (final user in users) {
      final List<MessageModel> sent =
          (sentBox.get(user.id)?.cast<MessageModel>()) ?? <MessageModel>[];
      final List<MessageModel> received = (receivedBox.get(user.id)?.cast<MessageModel>()) ?? <MessageModel>[];
      if (sent.isNotEmpty) hydratedSent[user] = sent;
      if (received.isNotEmpty) hydratedReceived[user] = received;
    }

    sendMessages.value = hydratedSent;
    receivedMessages.value = hydratedReceived;
  }

  /// Start advertising this device
  Future<void> _startAdvertising() async {
    try {
      await Nearby().startAdvertising(
        _composeEndpointName(),
        strategy,
        onConnectionInitiated: (id, info) {
          _connectionInfoMap[id] = info;
          _onConnectionInitiated(id, info);
        },
        onConnectionResult: (id, status) {
          _pendingConnections.remove(id);
          _onConnectionResult(id, status);
        },
        onDisconnected: _onDisconnected,
      );
      _isAdvertising = true;
      NearbyStateStorage.setIsAdvertising(true);
      print('Advertising as $_userName');
    } catch (e) {
      _isAdvertising = false;
      print('Advertising error: $e');
      rethrow;
    }
  }

  /// Start discovering other devices
  Future<void> _startDiscovery() async {
    try {
      await Nearby().startDiscovery(
        _userName,
        strategy,
        onEndpointFound: _onEndpointFound,
        onEndpointLost: _onEndpointLost,
      );
      _isDiscovering = true;
      _startProximityMonitoring();
      NearbyStateStorage.setIsDiscovering(true);
      print('Discovery started');
    } catch (e) {
      _isDiscovering = false;
      print('Discovery error: $e');
      rethrow;
    }
  }

  // Add proximity monitoring
  void _startProximityMonitoring() {
    _proximityTimer?.cancel();
    _proximityTimer = Timer.periodic(_proximityCheckInterval, (timer) {
      // Remove devices that take too long to connect
      final distantDevices = _connectionAttempts.entries
          .where((entry) => entry.value > _maxConnectionAttempts)
          .map((e) => e.key)
          .toList();

      for (final endpointId in distantDevices) {
        print('Removing distant device: $endpointId');
        _onEndpointLost(endpointId);
        Nearby().disconnectFromEndpoint(endpointId);
      }
    });
  }

  /// Handle new device discovery
  Future<void> _onEndpointFound(
    String endpointId,
    String userName,
    String serviceId,
  ) async {
    if (_pendingConnections.contains(endpointId)) return;

    // Track connection attempts
    _connectionAttempts[endpointId] =
        (_connectionAttempts[endpointId] ?? 0) + 1;

    // Skip if too many attempts (likely distant)
    if (_connectionAttempts[endpointId]! > _maxConnectionAttempts) {
      print('Skipping distant endpoint: $endpointId');
      return;
    }
    print('Found endpoint: $endpointId ($userName)');
    _pendingConnections.add(endpointId);

    // Parse endpointName to extract stable id and display name
    final parsed = _parseEndpointName(userName);
    final stableId = parsed.$2 ?? endpointId;
    final displayName = parsed.$1;

    // Add to discovered list and persist in Hive users box
    final newUser = ChatUserModel(id: stableId, userName: displayName, endpointId: endpointId);
    discoveredList.value = [
      ...discoveredList.value.where((u) => u.endpointId != endpointId && u.id != stableId),
      newUser,
    ];
    final usersBox = Hive.box<ChatUserModel>(kBoxUsers);
    await usersBox.put(stableId, newUser);

    await Nearby().requestConnection(
      _userName,
      endpointId,
      onConnectionInitiated: (id, info) {
        _connectionInfoMap[id] = info;
        _onConnectionInitiated(id, info);
      },
      onConnectionResult: (id, status) {
        _pendingConnections.remove(id);
        _onConnectionResult(id, status);
      },
      onDisconnected: _onDisconnected,
    );
  }

  /// Handle lost device
  void _onEndpointLost(String? endpointId) {
    print('Lost endpoint: $endpointId');
    _pendingConnections.remove(endpointId);

    // Update discovered list
    discoveredList.value = discoveredList.value
        .where((u) => u.endpointId != endpointId)
        .toList();

    // Update connected list
    connectedEndpoints.value = connectedEndpoints.value
        .where((u) => u.endpointId != endpointId)
        .toList();

    _connectedUsers.remove(endpointId);
  }

  /// Accept incoming connections
  void _onConnectionInitiated(String endpointId, ConnectionInfo info) {
    print('Connection initiated with ${info.endpointName} ($endpointId)');
    Nearby().acceptConnection(
      endpointId,
      onPayLoadRecieved: _onPayloadReceived,
      onPayloadTransferUpdate: _onPayloadTransferUpdate,
    );
  }

  /// Handle connection results
  void _onConnectionResult(String endpointId, Status status) {
    if (status == Status.CONNECTED) {
      _connectionAttempts.remove(endpointId);
      _connectionStability[endpointId] = 0; // Initialize stability counter
      _startConnectionMonitoring();
      _connectionAttempts.remove(endpointId);
      final info = _connectionInfoMap[endpointId];
      final parsed = _parseEndpointName(info?.endpointName ?? 'Unknown');
      final user = ChatUserModel(
        id: parsed.$2 ?? endpointId,
        userName: parsed.$1,
        endpointId: endpointId,
      );

      _connectedUsers[endpointId] = user;
      connectedEndpoints.value = [
        ...connectedEndpoints.value.where((u) => u.endpointId != endpointId && u.id != user.id),
        user,
      ];

      // Persist user in Hive
      final usersBox = Hive.box<ChatUserModel>(kBoxUsers);
      usersBox.put(user.id, user);

      print('Connected to ${user.userName}');
    } else {
      _connectionAttempts[endpointId] =
          (_connectionAttempts[endpointId] ?? 0) + 1;
      print('Connection failed to $endpointId: $status');
    }
  }

  void _startConnectionMonitoring() {
    _connectionMonitorTimer?.cancel();
    _connectionMonitorTimer = Timer.periodic(_connectionCheckInterval, (_) {
      _connectedUsers.keys.forEach((endpointId) {
        _checkConnectionHealth(endpointId);
      });
    });
  }

  void _checkConnectionHealth(String endpointId) {
    // Simulate RSSI check (replace with actual if available)
    final isWeakConnection =
        Random().nextDouble() > 0.7; // 30% chance of weak signal

    if (isWeakConnection) {
      _connectionStability[endpointId] =
          (_connectionStability[endpointId] ?? 0) + 1;

      if (_connectionStability[endpointId]! >= _maxStabilityThreshold) {
        _handleDistantDevice(endpointId);
      }
    } else {
      _connectionStability[endpointId] = 0; // Reset counter on good signal
    }
  }

  void _handleDistantDevice(String endpointId) {
    print('Device $endpointId moved out of range');
    Nearby().disconnectFromEndpoint(endpointId);
    _onDisconnected(endpointId);

    // Optional: Notify UI about disconnection reason
    receivedMessages.value = {
      ...receivedMessages.value,
      _connectedUsers[endpointId]!: [
        ...receivedMessages.value[_connectedUsers[endpointId]] ?? [],
        MessageModel(
          value: "SYSTEM: Connection lost (out of range)",
          createdTime: DateTime.now(),
        ),
      ],
    };
  }

  /// Handle disconnections
  void _onDisconnected(String endpointId) {
    print('Disconnected from $endpointId');

    _connectionStability.remove(endpointId);
    connectedEndpoints.value = connectedEndpoints.value
        .where((u) => u.id != endpointId)
        .toList();
    _connectedUsers.remove(endpointId);
    discoveredList.value = discoveredList.value
        .where((u) => u.id != endpointId)
        .toList();
    _connectedUsers.remove(endpointId);
  }

  void _onPayloadTransferUpdate(
    String endpointId,
    PayloadTransferUpdate update,
  ) {
    if (update.status == PayloadStatus.FAILURE) {
      _connectionStability[endpointId] =
          (_connectionStability[endpointId] ?? 0) + 1;
    }
  }

  String _composeEndpointName() {
    // Include display name and stable id so peers can map to a consistent user record
    final name = _userName;
    final id = _myId ?? '';
    return id.isEmpty ? name : '$name|$id';
  }

  /// Parses endpoint name of the form "Name|uuid", returns (name, uuid?)
  (String, String?) _parseEndpointName(String endpointName) {
    final parts = endpointName.split('|');
    if (parts.length >= 2) {
      return (parts[0], parts[1]);
    }
    return (endpointName, null);
  }

  /// Process incoming messages
  void _onPayloadReceived(String endpointId, Payload payload) {
    try {
      _connectionStability[endpointId] = 0;
      if (payload.bytes == null) return;

      final data = jsonDecode(utf8.decode(payload.bytes!));
      if (data['type'] == _messageType) {
        _handleMessageReceived(endpointId, data);
      }
      print(sendMessages.value);
      print(receivedMessages.value);
    } catch (e) {
      print('Payload processing error: $e');
    }
  }

  /// Handle chat messages
  void _handleMessageReceived(String endpointId, Map<String, dynamic> data) {
    final sender = _connectedUsers[endpointId];
    if (sender == null) return;

    final message = MessageModel.fromJson(data['message']);
    receivedMessages.value = {
      ...receivedMessages.value,
      sender: [...receivedMessages.value[sender] ?? [], message],
    };

    // Persist received message
    final box = Hive.box<List>(kBoxMessagesReceived);
    final List<MessageModel> current =
        (box.get(sender.id)?.cast<MessageModel>()) ?? <MessageModel>[];
    final updated = [...current, message];
    box.put(sender.id, updated);

    print('Message from ${sender.userName}: ${message.value}');
  }

  /// Send chat message
  void sendChatMessage(MessageModel message, ChatUserModel user) {
    try {
      final bytes = utf8.encode(
        jsonEncode({
          'type': _messageType,
          'message': message.toJson(),
          'createdTime': DateTime.now().toIso8601String(),
        }),
      );

      Nearby().sendBytesPayload(user.id, bytes);

      sendMessages.value = {
        ...sendMessages.value,
        user: [...sendMessages.value[user] ?? [], message],
      };

      // Persist sent message
      final box = Hive.box<List>(kBoxMessagesSent);
      final List<MessageModel> current =
          (box.get(user.id)?.cast<MessageModel>()) ?? <MessageModel>[];
      final updated = [...current, message];
      box.put(user.id, updated);

      print('Sent to ${user.userName}: ${message.value}');
    } catch (e) {
      print('Message send error: $e');
    }
  }

  /// Get current state
  bool get isAdvertising => _isAdvertising;
  bool get isDiscovering => _isDiscovering;
  List<ChatUserModel> get connectedUsers => connectedEndpoints.value;
  List<ChatUserModel> get discoveredUsers => discoveredList.value;
}
