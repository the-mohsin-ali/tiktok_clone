import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/widgets/message_bubble.dart';
import 'package:tiktok_clone/view/inbox_view/chat/attatchment_options_sheet.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view_controller.dart';

class ChatScreen extends GetView<ChatController> {
  final String otherUserId;
  final String? otherUserName;
  final String? otherUserPhoto;

  final TextEditingController messageController = TextEditingController();

  ChatScreen({required this.otherUserId, this.otherUserName, this.otherUserPhoto, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          final chat = controller.currentChat.value;

          // Default title and image to fallback values
          print('default values: username $otherUserName photo $otherUserPhoto');
          String title = otherUserName ?? 'New Chat';
          String? image = otherUserPhoto;

          if (chat != null) {
            final isGroup = chat.type.name == 'group';
            if (isGroup) {
              title = chat.groupName ?? 'Group';
              image = chat.groupPhoto;
            } else {
              final otherId = chat.participants.firstWhere((id) => id != controller.currentUserId);
              final user = controller.userCache[otherId];
              title = user?.userName ?? 'Chat';
              image = user?.profilePhoto;
            }
          }

          return AppBar(
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundImage: image != null ? NetworkImage(image) : null,
                  child: image == null ? Icon(Icons.person) : null,
                ),
                SizedBox(width: 8),
                Text(title, style: TextStyle(fontSize: 18)),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  // TODO: implement message search
                },
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 🧾 Messages
                Expanded(
                  child: Obx(() {
                    if (controller.isInitialLoading.value) {
        
                      return Center(child: CircularProgressIndicator());
                    }

                    final messages = controller.messages;

                    if (messages.isEmpty) {
                      return Center(child: Text("No messages yet"));
                    }

                    
                    return ListView.builder(
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                      reverse: false,
                      itemCount: messages.length + 1, 
                      itemBuilder: (_, index) {
                        if (index == messages.length) {
                          // Loader when paginating
                          return controller.isLoadingMore
                              ? Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox.shrink();
                        }

                        final msg = messages[index];
                        final isMe = msg.senderId == controller.currentUserId;
                        final sender = controller.userCache[msg.senderId];

                        return Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: MessageBubble(
                            message: msg,
                            isMe: isMe,
                            isGroup: controller.currentChat.value?.type.name == 'group',
                            sender: sender,
                          ),
                        );
                      },
                    );
                  }),
                ),

                // 📥 Input bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            builder: (_) => const AttachmentOptionsSheet(),
                          );
                          if (result != null) {
                            controller.handleMediaAttachment(
                              type: result,
                              otherUserId: otherUserId,
                              chatId: controller.currentChat.value?.id,
                            );
                          }
                        },
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () async {
                          final text = messageController.text.trim();
                          if (text.isNotEmpty) {
                            messageController.clear();
                            final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
                            final result = await controller.createOrGetDirectChat(currentUserId, otherUserId);
                            final chatId = result.item1;
                            final isNew = result.item2;

                            if (isNew) {
                              await controller.updateController(chatId);
                            }

                            await controller.sendMessage(chatId: chatId, senderId: currentUserId, text: text);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // 🔽 FAB scroll to bottom
            Obx(() {
              return controller.showScrollToBottomBtn.value
                  ? Positioned(
                      right: 20.w,
                      bottom: 80.h,
                      child: FloatingActionButton(
                        backgroundColor: Colors.grey[300],
                        shape: CircleBorder(),
                        mini: true,
                        onPressed: () {
                          controller.scrollController.animateTo(
                            controller.scrollController.position.maxScrollExtent,
                            duration: Duration(milliseconds: 100),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Icon(CupertinoIcons.down_arrow),
                      ),
                    )
                  : SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }
}
