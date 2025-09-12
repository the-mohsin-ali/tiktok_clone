import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/state_manager.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/inbox_view/chat/chat_view.dart';
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
          SizedBox(
            height: 60.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: 6, // demo items
              separatorBuilder: (_, __) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/men/75.jpg', // Replace with real photo
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ['Barry', 'Perez', 'Alvin', 'Dan', 'Amy', 'Nina'][index],
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Obx(() {
              final systemMessage = controller.system_message;
              if (systemMessage.isEmpty) {
                return Center(
                  child: Text("No messages yet", style: TextStyle(color: Colors.grey)),
                );
              }
              return ListView.separated(
                itemCount: systemMessage.length,
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Divider(height: 1, thickness: 1, color: Colors.grey[300]),
                  );
                },
                itemBuilder: (context, index) {
                  final msg = systemMessage[index];

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: CircleAvatar(
                      radius: 24.r,
                      backgroundImage: msg.userPhotoUrl.isNotEmpty
                          ? NetworkImage(msg.userPhotoUrl)
                          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    ),
                    title: Text(msg.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(msg.message, style: const TextStyle(), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: Text(timeago.format(msg.time), style: const TextStyle(fontSize: 12)),
                    onTap: () {
                      Get.to(ChatView());
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
