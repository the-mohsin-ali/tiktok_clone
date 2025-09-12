import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view_controller.dart';

class ChatView extends StatelessWidget {
  final ChatController controller = Get.put(ChatController(Get.arguments));

  @override
  Widget build(BuildContext context) {
    final chat = controller.chatModel;

    return Scaffold(
      appBar: AppBar(
        title: Text(chat.receiverName),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(chat.receiverPhotoUrl),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              return ListView.builder(
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final msg = controller.messages[index];
                  final isMe = msg.senderId == chat.senderId;

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.blueAccent : Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: "Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.grey[900],
                      filled: true,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
