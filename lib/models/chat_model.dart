import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String chatId;
  final String receiverId;
  final String senderId;
  final String message;
  final DateTime timeStamp;
  final String senderName;
  final String senderPhoto;

  const ChatModel({
    required this.chatId,
    required this.receiverId,
    required this.senderName,
    required this.senderId,
    required this.message,
    required this.senderPhoto,
    required this.timeStamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'receiverId': receiverId,
      'senderName': senderName,
      'senderId': senderId,
      'message': message,
      'senderPhoto': senderPhoto,
      'timeStamp': Timestamp.fromDate(timeStamp),
    };
  }

  factory ChatModel.fromJson(Map<String, dynamic> json, String chatId) {
    return ChatModel(
      chatId: chatId,
      receiverId: json['receiverId'],
      senderName: json['senderName'],
      senderId: json['senderId'],
      message: json['message'],
      senderPhoto: json['senderPhoto'],
      timeStamp: (json['timeStamp'] as Timestamp).toDate(),
    );
  }
}
