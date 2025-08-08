import 'package:flutter/material.dart';
import 'package:sample_app/models/chat_user_model.dart';
import 'package:sample_app/models/message_model.dart';

/// All devices we are connected to
ValueNotifier<List<ChatUserModel>> connectedEndpoints = ValueNotifier([]);

/// Only devices that meet our condition (e.g., nearby location)
ValueNotifier<List<ChatUserModel>> discoveredList = ValueNotifier([]);

ValueNotifier<Map<ChatUserModel, List<MessageModel>>> receivedMessages =
    ValueNotifier({});

ValueNotifier<Map<ChatUserModel, List<MessageModel>>> sendMessages =
    ValueNotifier({});

/// Hive box names
const String kBoxProfile = 'box_profile'; // stores a single UserProfile with key 'me'
const String kBoxUsers = 'box_users'; // key: userId, value: ChatUserModel
const String kBoxMessagesSent = 'box_messages_sent'; // key: userId, value: List<MessageModel>
const String kBoxMessagesReceived = 'box_messages_received'; // key: userId, value: List<MessageModel>