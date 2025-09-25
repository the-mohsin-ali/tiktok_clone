import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view_controller.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';
import 'package:timeago/timeago.dart' as timeago;

class InboxView extends GetView<InboxController> {
  const InboxView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Messages",
          style: TextStyle(
            // color: Colors.white,
            fontFamily: 'TikTokSansExpanded',
            fontWeight: FontWeight.w400,
            fontSize: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            iconSize: 25.h,
            icon: Icon(Icons.search, color: AppColor.buttonInactiveColor),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("RECENT", style: TextStyle(color: Colors.grey, letterSpacing: 1)),
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final chats = controller.inboxItems.where((item) => item.isChat).map((item) => item.chat!).toList();

            if (chats.isEmpty) {
              return SizedBox(
                height: 60.h,
                child: Center(child: Text("No recent chats")),
              );
            }

            chats.sort((a, b) => b.lastMessageAt!.compareTo(a.lastMessageAt!));

            final recentChats = chats.take(10).toList();

            return SizedBox(
              height: 60.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: recentChats.length,
                separatorBuilder: (_, __) => SizedBox(width: 16.w),
                itemBuilder: (context, index) {
                  final chat = recentChats[index];
                  final currentUserId = controller.auth.currentUser?.uid;
                  final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);

                  return FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                    builder: (context, asyncSnapshot) {
                      if (!asyncSnapshot.hasData) {
                        return Center(
                          child: Text(
                            "No recent chats",
                            style: TextStyle(fontFamily: 'TikTokSansExpanded', fontWeight: FontWeight.w400),
                          ),
                        );
                        // Column(
                        //   children: [
                        //     CircleAvatar(radius: 25.r, child: Icon(Icons.person)),
                        //     SizedBox(height: 4),
                        //     Text("...", style: TextStyle(fontSize: 12)),
                        //   ],
                        // );
                      }

                      final data = asyncSnapshot.data!.data() as Map<String, dynamic>;
                      final name = data['userName'] ?? 'User';
                      final photoUrl = data['profilePhoto'] ?? '';

                      return GestureDetector(
                        onTap: () async {
                          print("recent chat tapped");
                          if (Get.isRegistered<ChatController>()) {
                            final chatController = Get.find<ChatController>();
                            await chatController.updateController(chat.id);
                          }else{
                            Get.put(ChatController(chatId: chat.id, currentUserId: currentUserId!));
                          }
                          Get.to(() => ChatScreen(otherUserId: otherUserId));
                        },
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 25.r,
                              backgroundImage: photoUrl.isNotEmpty
                              ? NetworkImage(photoUrl)
                              : const AssetImage('assets/images/default_profile.jpg') as ImageProvider
                            ),
                            const SizedBox(height: 4),
                            Text(
                              name,
                              style: const TextStyle(fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final items = controller.inboxItems;
              if (items.isEmpty) {
                return Center(
                  child: Text(
                    "No messages yet",
                    // style: TextStyle(color: Colors.grey)
                  ),
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                  );
                },
                itemBuilder: (context, index) {
                  final item = items[index];

                  if (item.isSystemMessage) {
                    final sm = item.systemMessage!;
                    return ListTile(
                      leading: CircleAvatar(
                        // radius: 20.r,
                        backgroundImage: sm.userPhotoUrl.isNotEmpty
                            ? NetworkImage(sm.userPhotoUrl)
                            : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                      ),
                      title: Text(sm.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(
                        sm.message,
                        style: const TextStyle(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: SizedBox(
                        width: 20.w,
                        child: Text(
                          timeago.format(sm.time, locale: 'en_short').replaceAll('~', ''),
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                      onTap: () {
                        print('system message tapped');
                        controller.openOrCreateChatWith(sm.userId, sm.userName, sm.userPhotoUrl);
                      },
                    );
                  } else if (item.isChat) {
                    final chat = item.chat!;
                    final currentUserId = controller.auth.currentUser?.uid;
                    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return ListTile(
                            leading: CircleAvatar(child: Icon(Icons.person)),
                            title: Text("Loading..."),
                          );
                        }

                        final data = snapshot.data!.data() as Map<String, dynamic>;
                        final name = data['userName'] ?? 'User';
                        final photoUrl = data['profilePhoto'] ?? '';

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: photoUrl.isNotEmpty
                                ? NetworkImage(photoUrl)
                                : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                            // child: photoUrl.isEmpty ? Icon(Icons.person) : null,
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            chat.lastMessage ?? '',
                            style: const TextStyle(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: chat.lastMessageAt != null
                              ? SizedBox(
                                  width: 20.w,
                                  child: Text(
                                    timeago.format(chat.lastMessageAt!, locale: 'en_short').replaceAll('~', ''),
                                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                                  ),
                                )
                              : null,
                          onTap: () async {
                            print('user chat tapped');
                            if (Get.isRegistered<ChatController>()) {
                              final controller = Get.find<ChatController>();
                              await controller.updateController(chat.id);
                            } else {
                              Get.put(ChatController(chatId: chat.id, currentUserId: currentUserId!));
                            }

                            Get.to(() => ChatScreen(otherUserId: otherUserId));
                          },
                        );
                      },
                    );
                  }
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  String getOtherParticipantName(List<String> participants, String? currentUserId) {
    if (currentUserId == null) return 'Unknown';

    final otherUserId = participants.firstWhere((id) => id != currentUserId, orElse: () => 'Unknown');

    return otherUserId;
  }
}
