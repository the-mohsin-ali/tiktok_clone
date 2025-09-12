import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';
import 'package:tiktok_clone/view/profile_view/video_grid_item.dart';

class ProfileView extends GetView<ProfileViewController> {
  ProfileView({super.key});

  // final ProfileViewController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    print("user name in controller.userName.value: ${controller.userName.value}");
    return Scaffold(
      appBar: AppBar(
        // foregroundColor: AppColor.secondaryColor,
        title: Obx(
          () => Text(
            controller.userName.value,
            style: TextStyle(fontFamily: 'TikTokSansExpanded', fontWeight: FontWeight.w400),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              controller.logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.user.value;
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: user.profilePhoto != null && user.profilePhoto!.isNotEmpty
                          ? NetworkImage(user.profilePhoto!)
                          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    ),
                  ),
                  // SizedBox(width: 24.w,),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat(user.followingCount, 'Following'),
                      _buildStat(user.followersCount, 'Followers'),
                      _buildStat(controller.totalLikes.value, 'Likes'),
                    ],
                  ),
                ],
              ),
            ),
            Text(
              user.userName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.h),
            _buildVideoGrid(),
          ],
        );
      }),
    );
  }

  Widget _buildStat(int count, String label) {
    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
        ),
        Text(label, style: TextStyle(fontSize: 12.sp)),
      ],
    );
  }

  Widget _buildVideoGrid() {
    final videos = controller.userVideos;

    if (videos.isEmpty) {
      return Center(
        child: Text("No videos yet", style: TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return Expanded(
      child: GridView.builder(
        itemCount: videos.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 9 / 16,
          crossAxisSpacing: 4,
          mainAxisSpacing: 4,
        ),
        itemBuilder: (context, index) {
          final video = videos[index];
          return VideoGridItem(videoUrl: video.videoUrl, index: index, controller: Get.find<ProfileViewController>(),);
        },
      ),
    );
  }
}
