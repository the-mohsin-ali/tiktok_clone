import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/utils/rounded_button.dart';
import 'package:tiktok_clone/view/feed/search/searched_profile_controller.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_view.dart';
import 'package:tiktok_clone/view/profile_view/video_grid_item.dart';

class SearchedProfile extends StatelessWidget {
  final String uid;
  SearchedProfile({super.key, required this.uid});

  late SearchedProfileController controller = Get.put(SearchedProfileController(uid));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          controller.user.value?.userName ?? '',
          style: TextStyle(fontFamily: 'TikTokSansExpanded', fontWeight: FontWeight.w700),
        ),
      ),
      body: Obx(() {
        final profileData = controller.user.value;
        if (profileData == null) {
          return const Center(child: CircularProgressIndicator());
        }

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
                      backgroundImage: profileData.profilePhoto != null && profileData.profilePhoto!.isNotEmpty
                          ? NetworkImage(profileData.profilePhoto!)
                          : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    ),
                  ),
                  // SizedBox(width: 24.w,),
                  SizedBox(height: 24.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 50),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(profileData.followingCount, 'Following'),
                        _buildStat(profileData.followersCount, 'Followers'),
                        _buildStat(controller.totalLikes.value, 'Likes'),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 10),
                    child: controller.isCurrentUser
                           ? SizedBox.shrink()
                           : controller.isFollowing.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RoundedButton(
                                  titelColor: AppColor.secondaryColor,
                                  title: 'Message',
                                  color: AppColor.buttonInactiveColor,
                                  onTap: () => Get.to(() => InboxView()),
                                  height: 40.h,
                                  width: 100.w,
                                ),
                                SizedBox(width: 5.w),
                                RoundedButton(
                                  titelColor: AppColor.primaryColor,
                                  title: 'Followed',
                                  color: AppColor.buttonInactiveColor,
                                  onTap: () {
                                    controller.toggleFollow();
                                  },
                                  height: 40.h,
                                  width: 100.w,
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RoundedButton(
                                  titelColor: AppColor.secondaryColor,
                                  title: 'Follow',
                                  color: AppColor.buttonActiveColor,
                                  onTap: () {
                                    controller.toggleFollow();
                                  },
                                  height: 40.h,
                                  width: 100.w,
                                ),
                                SizedBox(width: 5.w),
                                RoundedButton(
                                  titelColor: AppColor.primaryColor,
                                  title: 'Message',
                                  color: AppColor.buttonInactiveColor,
                                  onTap: () {},
                                  height: 40.h,
                                  width: 100.w,
                                ),
                              ],
                            ),
                    ),
                ],
              ),
            ),
            Text(
              '@${profileData.userName}',
              style: TextStyle(fontSize: 18.sp, fontFamily: 'TikTokSansExpanded', fontWeight: FontWeight.w400),
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
          return VideoGridItem(
            videoUrl: video.videoUrl,
            index: index,
            controller: Get.find<SearchedProfileController>(),
          );
        },
      ),
    );
  }
}
