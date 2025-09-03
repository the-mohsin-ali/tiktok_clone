import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/feed/comments/comments_controller.dart';

class CommentsBottomsheet extends StatelessWidget {
  final VideoModel video;

  CommentsBottomsheet({super.key, required this.video});

  CommentsController controller = Get.put(CommentsController());

  @override
  Widget build(BuildContext context) {
    print("value in user profile: ${controller.profileUrl.value}");
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            // color: Theme.of(context).brightness == ThemeData.dark() ? App,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              Align(alignment: Alignment.center, child: Text("${video.commentCount} comments")),
              SizedBox(height: 10.h),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: video.commentCount,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Obx(
                        () => CircleAvatar(
                          radius: 10,
                          backgroundImage: video.profilePhoto != null && video.profilePhoto!.isNotEmpty
                              ? NetworkImage(video.profilePhoto!)
                              : AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                        ),
                      ),
                      // title: video.comment,
                    );
                  },
                ),
              ),
              SafeArea(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColor.secondaryColor,
                      backgroundImage: controller.profileUrl.value.isNotEmpty
                          ? NetworkImage(controller.profileUrl.value)
                          : AssetImage('assets/images/default_avatar.png') as ImageProvider,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Add Comment...',
                          filled: true,
                          fillColor: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]
                              : Colors.grey[200],
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    IconButton(
                      onPressed: () {
                        //To implement
                        //controller.postComment()
                      },
                      icon: Icon(Icons.send, size: 20.h, color: AppColor.buttonActiveColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
