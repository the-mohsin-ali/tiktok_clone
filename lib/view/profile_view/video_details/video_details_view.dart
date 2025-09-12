import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
// import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
// import 'package:tiktok_clone/view/profile_view/profile_view_controller.dart';
// import 'package:tiktok_clone/view/profile_view/video_details/video_details_controller.dart';

class VideoDetailsView extends StatelessWidget {
  final int initialIndex;
  final VideoListController controller;

  VideoDetailsView({super.key, required this.initialIndex, required this.controller});

  // ProfileViewController controller = Get.find<ProfileViewController>();
  // HomeController videoController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: AppColor.primaryColor,
      body: Stack(
        children: [
          Obx(
            () => PageView.builder(
              scrollDirection: Axis.vertical,
              controller: PageController(initialPage: initialIndex),
              itemCount: controller.userVideos.length,
              itemBuilder: (context, index) {
                final video = controller.userVideos[index];
                final currentUid = SharedPrefs.cachedUid;
                final isLiked = video.likedBy.contains(currentUid);
                print("value of isLiked in video details: $isLiked");
                return Stack(
                  children: [
                    VideoplayerItem(videoUrl: video.videoUrl),
                    SizedBox(width: 16.h),

                    Positioned(
                      bottom: 80.h,
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
                              fontFamily: 'TikTokSansSemiCondensed',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.h),
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
                              width: 42,
                              height: 42,
                              colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                            ),
                          ),
                          Text(
                            '${video.commentCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'TikTokSansSemiCondensed',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          InkWell(
                            onTap: () {
                              SharePlus.instance.share(ShareParams(text: 'check this out! ${video.videoUrl}'));
                            },
                            child: SvgPicture.asset(
                              'assets/icons/share_icon.svg',
                              width: 38,
                              height: 38,
                              colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                            ),
                          ),
                          Text(
                            '${video.shareCount}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'TikTokSansSemiCondensed',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          InkWell(
                            onTap: () {},
                            child: SvgPicture.asset(
                              'assets/icons/more.svg',
                              // width: 38,
                              // height: 38,
                              width: 25.w,
                              colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Positioned(
            top: 30.h,
            left: 5.w,
            child: IconButton(onPressed: () => Get.back(), icon: Icon(Icons.arrow_back_outlined), iconSize: 22.h),
          ),
        ],
      ),
    );
  }
}
