import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:tiktok_clone/models/video_model.dart';

class VideoPlaybackManager {
  final PageController pageController;
  final List<VideoPlayerController> videoControllers = [];

  VideoPlaybackManager({required List<VideoModel> videos, int initialIndex = 0})
    : pageController = PageController(initialPage: initialIndex) {
    _initControllers(videos);
  }

  void _initControllers(List<VideoModel> videos) {
    for (var v in videos) {
      final vc = VideoPlayerController.networkUrl(Uri.parse(v.videoUrl));
      vc.initialize().then((_) {
        vc.play();
      });
      videoControllers.add(vc);
    }
  }

  void dispose() {
    for (var vc in videoControllers) {
      vc.dispose();
    }
    pageController.dispose();
  }
}
