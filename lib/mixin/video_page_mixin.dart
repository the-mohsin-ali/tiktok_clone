import 'package:get/get.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:video_player/video_player.dart';

mixin VideoPageMixin on GetxController {
  final currentIndex = 0.obs;
  final Map<int, VideoPlayerController> videoControllers = {};

  void initController(int index, String url) async {
    if (!videoControllers.containsKey(index)) {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);
      videoControllers[index] = controller;
    }
  }

  void disposeController(int index) {
    if (videoControllers.containsKey(index)) {
      videoControllers[index]?.dispose();
      videoControllers.remove(index);
    }
  }

  void onPageChanged(int index, List<VideoModel> allVideos) {
    currentIndex.value = index;

    initController(index, allVideos[index].videoUrl);
    videoControllers[index]?.play();

    if (index + 1 < allVideos.length) {
      initController(index + 1, allVideos[index + 1].videoUrl);
    }
    if (index - 1 >= 0) {
      initController(index - 1, allVideos[index - 1].videoUrl);
    }

    videoControllers.keys.where((i) => (i - index).abs() > 1).toList().forEach(disposeController);
  }
}