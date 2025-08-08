import 'package:geolocator/geolocator.dart';

class ChatUserModel {
  final String id;
  final String userName;

  ChatUserModel({required this.id, required this.userName});

  ChatUserModel copyWith({
    String? id,
    String? userName,
  }) {
    return ChatUserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatUserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
