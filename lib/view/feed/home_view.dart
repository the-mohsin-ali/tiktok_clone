// import 'package:flutter_svg/svg.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:tiktok_clone/constants/utils/keyboard_animation_handler.dart';
// import 'package:tiktok_clone/services/shared_prefs.dart';
// import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/feed/search/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
import 'package:get/get.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isFetching = false;

    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Obx(() {
          final videos = controller.videos;

          if (videos.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is OverscrollNotification &&
                  notification.overscroll < 0 &&
                  controller.pageController.page == 0 &&
                  !controller.isLoading.value &&
                  !isFetching) {
                isFetching = true;
                controller.fetchVideos().whenComplete(() {
                  isFetching = false;
                });
              }
              return false;
            },
            child: Stack(
              children: [
                PageView.builder(
                  controller: controller.pageController,
                  scrollDirection: Axis.vertical,
                  itemCount: videos.length,
                  onPageChanged: (index) {
                    controller.onPageChanged(index, videos);
                    // if (index == controller.videos.length - 1) {
                    //   controller.fetchVideos(loadMore: true);
                    // }
                  },
                  itemBuilder: (context, index) {
                    final video = videos[index];
                    final videoController = controller.videoControllers[index];

                    if (videoController == null || !videoController.value.isInitialized) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // final currentUid = SharedPrefs.cachedUid;
                    // final isLiked = video.likedBy.contains(currentUid);

                    // if (index == controller.videos.length - 1) {
                    //   controller.fetchVideos(loadMore: true);
                    // }

                    return VideoPlayerItem(
                      // key: ValueKey(video.videoUrl), videoUrl: video.videoUrl
                      video: video,
                      videoController: videoController,
                      listController: controller,
                    );

                    // Stack(
                    //   key: ValueKey(video.videoId),
                    //   children: [
                    //     // Video player
                    //     VideoPlayerItem(
                    //       // key: ValueKey(video.videoUrl), videoUrl: video.videoUrl
                    //       video: video, controller: videoController
                    //       ),

                    //     // Top-right search icon
                    //     Positioned(
                    //       top: 40.h,
                    //       right: 20.h,
                    //       child: GestureDetector(
                    //         onTap: () => Get.to(() => SearchScreen()),
                    //         child: Icon(Icons.search_sharp, color: AppColor.buttonInactiveColor, size: 38),
                    //       ),
                    //     ),

                    //     // Right side buttons
                    //     Positioned(
                    //       bottom: 50.h,
                    //       right: 10.h,
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         children: [
                    //           Container(
                    //             height: 60.h, // slightly larger than avatar radius + overlap
                    //             width: 50.w,
                    //             child: Stack(
                    //               clipBehavior: Clip.none, // 👈 IMPORTANT: allow children to overflow
                    //               alignment: Alignment.topCenter,
                    //               children: [
                    //                 Positioned(
                    //                   top: 0,
                    //                   child: CircleAvatar(
                    //                     radius: 24.r,
                    //                     backgroundImage: video.profilePhoto != null && video.profilePhoto!.isNotEmpty
                    //                         ? NetworkImage(video.profilePhoto!)
                    //                         : AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                    //                   ),
                    //                 ),
                    //                 if (!video.isFollowingThisPoster)
                    //                   Positioned(
                    //                     bottom: 6,
                    //                     child: GestureDetector(
                    //                       onTap: () {
                    //                         controller.followUser(video.uid, video.videoId);
                    //                       },
                    //                       child: Image.asset(
                    //                         'assets/icons/plus_button.png',
                    //                         fit: BoxFit.cover,
                    //                         height: 20.h,
                    //                         width: 22.w,
                    //                       ),
                    //                     ),
                    //                   ),
                    //               ],
                    //             ),
                    //           ),

                    //           SizedBox(height: 10.h),
                    //           InkWell(
                    //             onTap: () => controller.addLike(video),
                    //             child: Image.asset(
                    //               isLiked ? 'assets/icons/like_icon_filled.png' : 'assets/icons/like_icon.png',
                    //               key: ValueKey(isLiked),
                    //               width: 42.w,
                    //               height: 42.h,
                    //             ),
                    //           ),
                    //           Text('${video.likeCount}', style: TextStyle(color: Colors.white)),
                    //           SizedBox(height: 10.h),
                    //           InkWell(
                    //             onTap: () {
                    //               print("comment button tapped");

                    //               // ADD KEYBOARD OPTIMIZATION BEFORE SHOWING BOTTOM SHEET
                    //               KeyboardAnimationHandler.optimizeKeyboardPerformance();

                    //               showModalBottomSheet(
                    //                 isScrollControlled: true,
                    //                 context: context,
                    //                 // ADD THESE PARAMETERS FOR BETTER PERFORMANCE
                    //                 useSafeArea: true,
                    //                 isDismissible: true,
                    //                 enableDrag: true,
                    //                 showDragHandle: false,
                    //                 builder: (context) {
                    //                   return Padding(
                    //                     padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    //                     child: CommentsBottomsheet(video: video),
                    //                   );
                    //                 },
                    //               );
                    //             },
                    //             child: SvgPicture.asset(
                    //               'assets/icons/comment_icon.svg',
                    //               width: 38.w,
                    //               height: 38.h,
                    //               colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                    //             ),
                    //           ),
                    //           Text('${video.commentCount}', style: TextStyle(color: Colors.white)),
                    //           SizedBox(height: 10.h),
                    //           InkWell(
                    //             onTap: () {
                    //               SharePlus.instance.share(ShareParams(text: 'check this out! ${video.videoUrl}'));
                    //             },
                    //             child: SvgPicture.asset(
                    //               'assets/icons/share_icon.svg',
                    //               width: 32.w,
                    //               height: 32.h,
                    //               colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                    //             ),
                    //           ),
                    //           Text("${video.shareCount}", style: TextStyle(color: Colors.white)),
                    //         ],
                    //       ),
                    //     ),

                    //     // Loading indicator at top
                    //     Obx(
                    //       () => controller.isLoading.value
                    //           ? Align(
                    //               alignment: Alignment.topCenter,
                    //               child: Padding(
                    //                 padding: EdgeInsets.only(top: 20.h),
                    //                 child: CircularProgressIndicator(color: AppColor.buttonActiveColor),
                    //               ),
                    //             )
                    //           : SizedBox.shrink(),
                    //     ),
                    //   ],
                    // );
                  },
                ),

                // 🔎 Global Search Button
                Positioned(
                  top: 40.h,
                  right: 20.w,
                  child: GestureDetector(
                    onTap: () => Get.to(() => SearchScreen()),
                    child: Icon(Icons.search_sharp, color: AppColor.buttonInactiveColor, size: 38),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
