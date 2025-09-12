import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:tiktok_clone/models/chat_model.dart';

class ChatController extends GetxController {
  final ChatModel chatModel;

  ChatController(this.chatModel);

  final messages = <MessageModel>[].obs;
  final messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    listenToMessages();
  }

  void listenToMessages() {
    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatModel.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      messages.value = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data());
      }).toList();
    });
  }

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final newMessage = {
      'text': text,
      'senderId': chatModel.senderId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    FirebaseFirestore.instance
        .collection('chats')
        .doc(chatModel.chatId)
        .collection('messages')
        .add(newMessage);

    messageController.clear();
  }
}
