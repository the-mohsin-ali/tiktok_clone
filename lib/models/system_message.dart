import 'package:cloud_firestore/cloud_firestore.dart';

class SystemMessage {
  final String userId;
  final String userName;
  final String userPhotoUrl;
  final String message;
  final DateTime time;

  SystemMessage({
    required this.userId,
    required this.userName,
    required this.userPhotoUrl,
    required this.message,
    required this.time,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'message': message,
      'time': Timestamp.fromDate(time),
    };
  }

  factory SystemMessage.fromJson(Map<String, dynamic> json) {
    return SystemMessage(
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      message: json['message'],
      time: (json['time'] as Timestamp).toDate(),
    );
  }
}
