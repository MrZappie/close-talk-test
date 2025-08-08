import 'dart:convert';

class MessageModel {
  final String value;
  final DateTime createdTime;

  MessageModel({required this.value, required this.createdTime});

  Map<String, dynamic> toJson() {
    return {'value': value, 'createdTime': createdTime.toIso8601String()};
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      value: json['value'],
      createdTime: DateTime.parse(json['createdTime']),
    );
  }

  /// Optional: convert to bytes for Bluetooth transmission
  List<int> toBytes() {
    return utf8.encode(jsonEncode(toJson()));
  }

  /// Optional: create from bytes received via Bluetooth
  factory MessageModel.fromBytes(List<int> bytes) {
    return MessageModel.fromJson(jsonDecode(utf8.decode(bytes)));
  }
}
