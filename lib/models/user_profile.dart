class UserProfile {
  final String id; // could be device id or generated UUID
  final String userName;

  UserProfile({required this.id, required this.userName});

  UserProfile copyWith({String? id, String? userName}) =>
      UserProfile(id: id ?? this.id, userName: userName ?? this.userName);
}


