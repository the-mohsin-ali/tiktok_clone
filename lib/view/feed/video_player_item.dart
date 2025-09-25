import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/utils/keyboard_animation_handler.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
import 'package:tiktok_clone/view/feed/home_controller.dart';
import 'package:tiktok_clone/view/feed/search/search_screen.dart';
import 'package:video_player/video_player.dart';

// class VideoplayerItem extends StatefulWidget {
//   final String videoUrl;
//   const VideoplayerItem({super.key, required this.videoUrl});

//   @override
//   State<VideoplayerItem> createState() => _VideoplayerItemState();
// }

// class _VideoplayerItemState extends State<VideoplayerItem> {
//   late VideoPlayerController _videoPlayerController;

//   @override
//   void initState() {
//     super.initState();
//     // if (_videoPlayerController != null) {
//     //   await _videoPlayerController.dispose();
//     // }
//     _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
//       ..initialize().then((_) {
//         setState(() {});
//         _videoPlayerController.play();
//         _videoPlayerController.setLooping(true);
//       });
//   }

//   @override

//   void dispose() {
//     _videoPlayerController.dispose();
//     super.dispose();
//   }

//   void _togglePlayPause() {
//     if (_videoPlayerController.value.isPlaying) {
//       _videoPlayerController.pause();
//     } else {
//       _videoPlayerController.play();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return _videoPlayerController.value.isInitialized
//         ? GestureDetector(onTap: _togglePlayPause, child: VideoPlayer(_videoPlayerController))
//         : Center(child: CircularProgressIndicator());
//   }
// }

class VideoPlayerItem extends StatelessWidget {
  final VideoPlayerController? videoController;
  final VideoModel video;
  // final listController listController = Get.find();
  final VideoListController listController;

  VideoPlayerItem({super.key, required this.videoController, required this.video, required this.listController});

  void _togglePlayPause() {
    if (videoController!.value.isPlaying) {
      videoController!.pause();
    } else {
      videoController!.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = SharedPrefs.cachedUid;
    final isLiked = video.likedBy.contains(currentUid);

    return Stack(
      children: [
        Positioned.fill(
          child: videoController != null && videoController!.value.isInitialized
              ? GestureDetector(onTap: _togglePlayPause, child: VideoPlayer(videoController!))
              : const Center(child: CircularProgressIndicator()),
        ),

        // // 🔎 Search button (top-right)
        // Positioned(
        //   top: 40.h,
        //   right: 20.h,
        //   child: GestureDetector(
        //     onTap: () => Get.to(() => SearchScreen()),
        //     child: Icon(Icons.search_sharp, color: AppColor.buttonInactiveColor, size: 38),
        //   ),
        // ),

        // 👉 Right-side buttons (profile, like, comment, share)
        Positioned(
          bottom: 50.h,
          right: 10.h,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile + follow button
              SizedBox(
                height: 60.h,
                width: 50.w,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    Positioned(
                      top: 0,
                      child: CircleAvatar(
                        radius: 24.r,
                        backgroundImage: video.profilePhoto != null && video.profilePhoto!.isNotEmpty
                            ? NetworkImage(video.profilePhoto!)
                            : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                      ),
                    ),
                    if (!video.isFollowingThisPoster)
                      Positioned(
                        bottom: 6,
                        child: GestureDetector(
                          onTap: () => listController.followUser(video.uid, video.videoId),
                          child: Image.asset(
                            'assets/icons/plus_button.png',
                            fit: BoxFit.cover,
                            height: 20.h,
                            width: 22.w,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              SizedBox(height: 10.h),

              // ❤️ Like button
              InkWell(
                onTap: () => listController.addLike(video),
                child: Image.asset(
                  isLiked ? 'assets/icons/like_icon_filled.png' : 'assets/icons/like_icon.png',
                  key: ValueKey(isLiked), // ensures animation refresh
                  width: 42.w,
                  height: 42.h,
                ),
              ),
              Text('${video.likeCount}', style: const TextStyle(color: Colors.white)),

              SizedBox(height: 10.h),

              // 💬 Comment button
              InkWell(
                onTap: () {
                  KeyboardAnimationHandler.optimizeKeyboardPerformance();

                  showModalBottomSheet(
                    isScrollControlled: true,
                    context: context,
                    useSafeArea: true,
                    isDismissible: true,
                    enableDrag: true,
                    showDragHandle: false,
                    builder: (context) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: CommentsBottomsheet(video: video),
                      );
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
              Text('${video.commentCount}', style: const TextStyle(color: Colors.white)),

              SizedBox(height: 10.h),

              // 🔗 Share button
              InkWell(
                onTap: () {
                  SharePlus.instance.share(ShareParams(text: 'check this out! ${video.videoUrl}'));
                },
                child: SvgPicture.asset(
                  'assets/icons/share_icon.svg',
                  width: 32.w,
                  height: 32.h,
                  colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                ),
              ),
              Text("${video.shareCount}", style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),

        // ⏳ Loading indicator (top-center)
        Obx(
          () => listController.isLoading.value
              ? Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.h),
                    child: CircularProgressIndicator(color: AppColor.buttonActiveColor),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
