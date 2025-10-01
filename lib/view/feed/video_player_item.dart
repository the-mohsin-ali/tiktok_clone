import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/constants/utils/keyboard_animation_handler.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/main.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';
import 'package:tiktok_clone/view/feed/comments/comments_bottomsheet.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoModel video;
  final VideoListController listController;

  const VideoPlayerItem({super.key, required this.video, required this.listController});

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> with WidgetsBindingObserver, RouteAware {
  late VideoPlayerController _videoPlayerController;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.video.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          setState(() {
            _isReady = true;
          });
          _videoPlayerController.play();
          _videoPlayerController.setLooping(true);
        }
      });

    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // ✅ subscribe to routeObserver
    final ModalRoute? route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _videoPlayerController.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoPlayerController.play();
    }
  }

  @override
  void didPushNext() {
    // agar dusri full screen route hai (PageRoute), tabhi pause karo
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _videoPlayerController.pause();
    }
  }

  @override
  void didPopNext() {
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      _videoPlayerController.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    routeObserver.unsubscribe(this);
    _videoPlayerController.dispose();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    print("[_togglePlayPause()] video tapped");

    if (_videoPlayerController.value.isPlaying) {
      print("[_togglePlayPause()] Before tap -> isPlaying: ${_videoPlayerController.value.isPlaying}");
      await _videoPlayerController.pause();
      print("[_togglePlayPause()] After pause -> isPlaying: ${_videoPlayerController.value.isPlaying}");
    } else {
      await _videoPlayerController.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUid = SharedPrefs.cachedUid;
    final isLiked = widget.video.likedBy.contains(currentUid);

    return SafeArea(
      child: Stack(
        children: [
          // 🎥 Main video area
          Positioned.fill(
            child: _isReady
                ? GestureDetector(
                    onTap: _togglePlayPause,
                    child: Stack(
                      children: [
                        VideoPlayer(_videoPlayerController),
                        ValueListenableBuilder(
                          valueListenable: _videoPlayerController,
                          builder: (context, VideoPlayerValue value, child) {
                            if (value.isPlaying) {
                              return SizedBox.shrink();
                            }
                            return Center(
                              child: Image.asset(
                                'assets/icons/play_icon.png',
                                width: 45.w,
                                height: 45.h,
                                color: Colors.white.withValues(alpha: 0.3),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                : Container(
                    color: AppColor.primaryColor,
                    child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                  ),
          ),

          // 👉 Right-side buttons
          Positioned(
            bottom: 70.h,
            right: 10.h,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 👤 Profile + follow button
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
                          backgroundImage: widget.video.profilePhoto != null && widget.video.profilePhoto!.isNotEmpty
                              ? NetworkImage(widget.video.profilePhoto!)
                              : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                        ),
                      ),
                      if (!widget.video.isFollowingThisPoster)
                        Positioned(
                          bottom: 6,
                          child: GestureDetector(
                            onTap: () => widget.listController.followUser(widget.video.uid, widget.video.videoId),
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

                // ❤️ Like
                InkWell(
                  onTap: () => widget.listController.addLike(widget.video),
                  child: Image.asset(
                    isLiked ? 'assets/icons/like_icon_filled.png' : 'assets/icons/like_icon.png',
                    key: ValueKey(isLiked),
                    width: 32.w,
                    height: 32.h,
                  ),
                ),
                Text('${widget.video.likeCount}', style: const TextStyle(color: Colors.white)),

                SizedBox(height: 10.h),

                // 💬 Comment
                InkWell(
                  onTap: () {
                    // KeyboardAnimationHandler.optimizeKeyboardPerformance();

                    showModalBottomSheet(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent, // taake hum apna custom container de saken
                      builder: (context) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: DraggableScrollableSheet(
                            expand: false,
                            initialChildSize: 0.7,
                            minChildSize: 0.4,
                            maxChildSize: 0.95,
                            builder: (_, scrollController) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(16.r),
                                    topRight: Radius.circular(16.r),
                                  ),
                                ),
                                child: CommentsBottomsheet(
                                  video: widget.video,
                                  scrollController: scrollController, // pass if needed
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/icons/comment_icon.svg',
                    width: 32.w,
                    height: 32.h,
                    colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                  ),
                ),
                Text('${widget.video.commentCount}', style: const TextStyle(color: Colors.white)),

                SizedBox(height: 10.h),

                // 🔗 Share
                InkWell(
                  onTap: () {
                    SharePlus.instance.share(ShareParams(text: 'check this out! ${widget.video.videoUrl}'));
                  },
                  child: SvgPicture.asset(
                    'assets/icons/share_icon.svg',
                    width: 26.w,
                    height: 26.h,
                    colorFilter: ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn),
                  ),
                ),
                Text("${widget.video.shareCount}", style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),

          // ⏳ Loading indicator
          Obx(
            () => widget.listController.isLoading.value
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
      ),
    );
  }
}
