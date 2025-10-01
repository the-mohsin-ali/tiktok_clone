import 'package:flutter/material.dart';
import 'package:tiktok_clone/core/video_playback_manager.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/view/feed/video_player_item.dart';
import 'package:get/get.dart';

class VideoDetailsView extends StatefulWidget {
  final int initialIndex;
  final VideoListController listController;

  const VideoDetailsView({
    super.key,
    required this.initialIndex,
    required this.listController,
  });

  @override
  State<VideoDetailsView> createState() => _VideoDetailsViewState();
}

class _VideoDetailsViewState extends State<VideoDetailsView> {
  late VideoPlaybackManager playbackManager;

  @override
  void initState() {
    super.initState();
    playbackManager = VideoPlaybackManager(
      videos: widget.listController.userVideos,
      initialIndex: widget.initialIndex,
    );
  }

  @override
  void dispose() {
    playbackManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Obx(() {
            final videos = widget.listController.userVideos;
            return PageView.builder(
              controller: playbackManager.pageController,
              scrollDirection: Axis.vertical,
              itemCount: videos.length,
              itemBuilder: (context, index) {
                final video = videos[index];
                final vc = playbackManager.videoControllers[index];

                return VideoPlayerItem(
                  video: video,
                  listController: widget.listController,
                );
              },
            );
          }),
          Positioned(
            top: 30,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_outlined),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }
}
