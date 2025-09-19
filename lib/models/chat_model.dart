import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tiktok_clone/models/enumns.dart';

class ChatModel {
final String id;
final ChatType type;
final List<String> participants;
final String? groupName;
final String? groupPhoto;
final String? lastMessage;
final String? lastMessageBy;
final DateTime? lastMessageAt;

ChatModel({
required this.id,
required this.type,
required this.participants,
this.groupName,
this.groupPhoto,
this.lastMessage,
this.lastMessageBy,
this.lastMessageAt,
});

factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
return ChatModel(
id: id,
type: json['type'] == 'group' ? ChatType.group : ChatType.direct,
participants: List<String>.from(json['participants'] ?? []),
groupName: json['groupName'],
groupPhoto: json['groupPhoto'],
lastMessage: json['lastMessage'],
lastMessageBy: json['lastMessageBy'],
lastMessageAt: (json['lastMessageAt'] as Timestamp?)?.toDate(),
);
}

Map<String, dynamic> toJson() {
return {
'type': type.name,
'participants': participants,
'groupName': groupName,
'groupPhoto': groupPhoto,
'lastMessage': lastMessage,
'lastMessageBy': lastMessageBy,
'lastMessageAt': lastMessageAt,
};
}
}