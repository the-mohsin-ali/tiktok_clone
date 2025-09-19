import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiktok_clone/models/enumns.dart';

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? createdAt;
  final List<String> readBy;
  final String? mediaUrl;
  final String? thumbnail;
  final MessageType messageType;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
    required this.readBy,
    this.mediaUrl,
    this.thumbnail,
    required this.messageType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json, String id) {
    DateTime? parsedCreatedAt;
    final rawTimestamp = json['createdAt'];
    if (rawTimestamp is Timestamp) {
      parsedCreatedAt = rawTimestamp.toDate();
    }
    return MessageModel(
      id: id,
      senderId: json['senderId'] ?? '',
      text: json['text'] ?? '',
      mediaUrl: json['mediaUrl'],
      thumbnail: json['thumbNail'],
      createdAt: parsedCreatedAt,
      readBy: List<String>.from(json['readBy'] ?? []),
      messageType: MessageType.values.firstWhere(
        (e) => e.name == (json['messageType'] ?? 'text'),
        orElse: () => MessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson({bool useServerTimestamp = false}) {
    return {
      'senderId': senderId,
      'text': text,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnail,
      'createdAt': useServerTimestamp && createdAt == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(createdAt ?? DateTime.now()),
      'readBy': readBy,
      'messageType': messageType.name,
    };
  }
}
