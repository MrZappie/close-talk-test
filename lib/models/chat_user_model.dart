class ChatUserModel {
  /// Permanent unique id for the device/user (stable across sessions)
  final String id;

  /// Friendly display name
  final String userName;

  /// Ephemeral Nearby endpoint id for the current session (can be null when offline)
  final String? endpointId;

  ChatUserModel({required this.id, required this.userName, this.endpointId});

  ChatUserModel copyWith({String? id, String? userName, String? endpointId}) {
    return ChatUserModel(
      id: id ?? this.id,
      userName: userName ?? this.userName,
      endpointId: endpointId ?? this.endpointId,
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
