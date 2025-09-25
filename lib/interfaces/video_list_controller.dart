import 'package:get/get.dart';
import 'package:tiktok_clone/models/video_model.dart';

abstract class VideoListController {
  RxList<VideoModel> get userVideos;
  void addLike(VideoModel video);
  void followUser(String uid, String videoId);
  RxBool get isLoading;
}
