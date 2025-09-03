import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFetching = false;
    // final video = controller.videos.value;

    return Obx(() {
      final videos = controller.videos;
      print('value of videos in home_view: $videos');

      return Theme(
        data: ThemeData.dark(),
        child: Scaffold(
          body: videos.isEmpty
              ? Center(child: CircularProgressIndicator())
              : NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is OverscrollNotification &&
                        notification.overscroll < 0 &&
                        controller.pageController.page == 0 &&
                        !controller.isLoading.value &&
                        !isFetching) {
                      isFetching = true;
                      print("vertical drag down triggered: fetching videos...");
                      controller.fetchVideos().whenComplete(() {
                        isFetching = false;
                      });
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      final video = videos[index];
                      final currentUid = SharedPrefs.cachedUid;
                      final isLiked = video.likedBy.contains(currentUid);

                      print("User ID: $currentUid");
                      print("LikedBy List: ${video.likedBy}");
                      print("IsLiked: $isLiked");

                      return Stack(
                        key: ValueKey(video.videoId),
                        children: [
                          VideoplayerItem(key: ValueKey(video.videoUrl), videoUrl: video.videoUrl),

                          SizedBox(width: 16.h),

                          Positioned(
                            bottom: 50.h,
                            right: 10.h,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 25,
                                  backgroundImage: video.profilePhoto != null && video.profilePhoto!.isNotEmpty
                                      ? NetworkImage(video.profilePhoto!)
                                      : AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                                ),
                                SizedBox(height: 10.h),
                                InkWell(
                                  onTap: () {
                                    controller.addLike(video);
                                  },
                                  child: Image.asset(
                                    isLiked ? 'assets/icons/like_icon_filled.png' : 'assets/icons/like_icon.png',
                                    key: ValueKey(isLiked),
                                    width: 42.w,
                                    height: 42.h,
                                  ),
                                ),
                                Text(
                                  '${video.likeCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ProximaNova',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                InkWell(
                                  onTap: () {
                                    print("comment button tapped");
                                    showModalBottomSheet(
                                      isScrollControlled: true,
                                      context: context,
                                      builder: (context) {
                                        return CommentsBottomsheet(video: video);
                                      },
                                    );
                                  },
                                  child: SvgPicture.asset(
                                    'assets/icons/comment_icon.svg',
                                    width: 38.w,
                                    height: 38.h,
                                    colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                                  ),
                                ),
                                Text(
                                  '${video.commentCount}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ProximaNova',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                SvgPicture.asset(
                                  'assets/icons/share_icon.svg',
                                  width: 32.w,
                                  height: 32.h,
                                  colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                                ),
                                Text(
                                  'Share',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'ProximaNova',
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Obx(
                            () => AnimatedAlign(
                              duration: Durations.extralong4,
                              alignment: controller.isLoading.value ? Alignment.center : Alignment(0, -2),

                              child: CircularProgressIndicator(color: AppColor.buttonActiveColor),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
        ),
      );
    });
  }
}
