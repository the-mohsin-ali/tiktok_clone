import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';
import 'package:video_player/video_player.dart';

class HomeController extends GetxController implements VideoListController {
  RxBool isLoading = false.obs;

  final PageController pageController = PageController();

  RxList<VideoModel> videos = <VideoModel>[].obs;

  final videoControllers = <int, VideoPlayerController>{}.obs;
  var currentIndex = 0.obs;

  int maxActiveControllers = 3;

  final RxBool isFollowing = false.obs;

  bool _isFetching = false;
  DocumentSnapshot? _lastDocument;
  final int _pageSize = 5;

  // final List<VideoPlayerController> videoControllers = [];

  @override
  void onInit() {
    super.onInit();
    print("onInit of home_controller called");
    fetchVideos();
    // _listenToVideosStream();
  }

  @override
  void onClose() {
    print("[HomeController] onClose() called");

    for (var controller in videoControllers.values) {
      try {
        controller.pause();
        controller.dispose();
      } catch (_) {}
    }
    videoControllers.clear();
    super.onClose();
  }

  Future<bool> initController(int index, String url) async {
    if (videoControllers.containsKey(index)) return true;

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      controller.setLooping(true);

      videoControllers[index] = controller;

      _logControllerCounts('init index $index');

      return true;
    } catch (e) {
      print("[HomeController] failed to init controller for $index: $e");
      return false;
    }
  }

  void pauseController(int index) {
    final c = videoControllers[index];
    if (c != null && c.value.isPlaying) {
      try {
        c.pause();
      } catch (_) {}
    }
  }

  void playController(int index) {
    final c = videoControllers[index];
    if (c != null && !c.value.isPlaying) {
      try {
        c.play();
      } catch (_) {}
    }
  }

  void disposeController(int index) {
    final c = videoControllers[index];
    if (c != null) {
      try {
        c.pause();
        c.dispose();
      } catch (_) {}
      videoControllers.remove(index);
      _logControllerCounts('dispose index $index');
    }
  }

  void _logControllerCounts(String reason) {
    print(
      '[HomeController] controllers: ${videoControllers.length} after $reason | keys=${videoControllers.keys.toList()}',
    );
  }

  void onPageChanged(int index, List<VideoModel> allVideos) {
    print("onPageChanged() called");

    currentIndex.value = index;

    // ✅ Init & play current video safely
    initController(index, allVideos[index].videoUrl).then((ok) {
      if (ok) {
        playController(index);
      } else {
        print("[onPageChanged] Skipping current video at index $index due to init failure.");
      }
    });

    // ✅ Preload next video safely
    if (index + 1 < allVideos.length) {
      initController(index + 1, allVideos[index + 1].videoUrl).then((ok) {
        if (!ok) {
          print("[onPageChanged] Skipped preload for ${index + 1}");
        }
      });
    }

    // ✅ Preload previous video safely
    if (index - 1 >= 0) {
      initController(index - 1, allVideos[index - 1].videoUrl).then((ok) {
        if (!ok) {
          print("[onPageChanged] Skipped preload for ${index - 1}");
        }
      });
    }

    // ✅ Pause any controller that's not current
    for (final key in videoControllers.keys.toList()) {
      if (key != index) {
        pauseController(key);
      }
    }

    // ✅ Dispose controllers farther than allowed window
    final allowed = <int>{index};
    if (maxActiveControllers >= 2 && index + 1 < allVideos.length) {
      allowed.add(index + 1);
    }
    if (maxActiveControllers >= 3 && index - 1 >= 0) {
      allowed.add(index - 1);
    }

    videoControllers.keys.where((i) => !allowed.contains(i)).toList().forEach(disposeController);

    // ✅ Pagination trigger
    if (index >= allVideos.length - 1) {
      fetchVideos(loadMore: true);
    }
  }

  Future<void> checkIfFollowingForVideo(VideoModel video) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final posterUid = video.uid;

    final doc = await FirebaseFirestore.instance.collection('users').doc(posterUid).get();
    final followers = List<String>.from(doc.data()?['followers'] ?? []);

    final index = videos.indexWhere((v) => v.videoId == video.videoId);
    if (index != -1) {
      videos[index] = video.copyWith(isFollowingThisPoster: followers.contains(currentUid));
      videos.refresh();
    }
  }

  Future<void> fetchVideos({bool loadMore = false}) async {
    if (_isFetching) return;

    _isFetching = true;

    print("[HomeController] fetchVideos() called");
    isLoading.value = true;
    try {
      Query query = FirebaseFirestore.instance
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .limit(_pageSize);

      if (loadMore && _lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;

        final newVideos = snapshot.docs
            .map((doc) => VideoModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
            .toList();

        if (loadMore) {
          videos.addAll(newVideos);
        } else {
          videos.assignAll(newVideos);
        }

        print('[fetchVideos] length of videos: ${videos.length}');

        for (final video in newVideos) {
          checkIfFollowingForVideo(video);
        }
      }
    } catch (e) {
      Utils.snackBar('Error', 'error fetching videos from database');
      print('[fetchVideos()] error fetching videos from database: $e');
    } finally {
      isLoading.value = false;
      _isFetching = false;
    }
  }

  final Map<String, Timer> _debounceTimers = {};

  Future<void> addLike(VideoModel video) async {
    final videoId = video.videoId;

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = video.likedBy.contains(currentUid);

    int index = videos.indexWhere((v) => v.videoId == videoId);
    if (index != -1) {
      final updatedLikedBy = List<String>.from(video.likedBy);
      int updatedLikeCount = video.likeCount;
      if (isLiked) {
        updatedLikedBy.remove(currentUid);
        updatedLikeCount -= 1;
      } else {
        updatedLikedBy.add(currentUid);
        updatedLikeCount += 1;
      }
      videos[index] = video.copyWith(likedBy: updatedLikedBy, likeCount: updatedLikeCount);
      videos.refresh(); // Force UI update
    }

    _debounceTimers[videoId]?.cancel();

    _debounceTimers[videoId] = Timer(const Duration(milliseconds: 500), () async {
      final docRef = FirebaseFirestore.instance.collection('videos').doc(video.videoId);
      final userRef = FirebaseFirestore.instance.collection('users').doc(video.uid);
      try {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final videoSnapshot = await transaction.get(docRef);
          final userSnapshot = await transaction.get(userRef);

          if (!videoSnapshot.exists || !userSnapshot.exists) {
            throw Exception('Document does not exists');
          }

          final currentLikes = userSnapshot.data()?['likes'] ?? 0;

          transaction.update(docRef, {
            'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
            'likeCount': isLiked ? video.likeCount - 1 : video.likeCount + 1,
          });

          if (isLiked && currentLikes <= 0) {
          } else {
            transaction.update(userRef, {'likes': FieldValue.increment(isLiked ? -1 : 1)});
          }
        });
      } catch (e) {
        print('Error toggling like: $e');
        Utils.snackBar('Error', 'Failed to toggle like');
      } finally {
        _debounceTimers.remove(videoId);
      }
    });
  }

  Future<void> followUser(String posterUid, String videoId) async {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final userRef = FirebaseFirestore.instance.collection('users').doc(posterUid);

    try {
      await userRef.update({
        'followers': FieldValue.arrayUnion([currentUid]),
      });

      // Update local state
      final index = videos.indexWhere((v) => v.videoId == videoId);
      if (index != -1) {
        videos[index] = videos[index].copyWith(isFollowingThisPoster: true);
        videos.refresh();
      }

      Utils.snackBar('Success', 'You are now following the user.');

      final followerUserSnapshot = await userRef.get();

      if (!followerUserSnapshot.exists) return;

      final followedUser = UserModel.fromMap(followerUserSnapshot.data()!);

      final inboxController = Get.find<InboxController>();

      if (!inboxController.hasFollowPrompt(followedUser.uid)) {
        inboxController.addFollowPrompt(isReverse: false, user: followedUser);
      }

      _sendReversePromptToFollowedUserInbox();
    } catch (e) {
      Utils.snackBar('Error', 'Failed to follow user.');
    }
  }

  Future<void> _sendReversePromptToFollowedUserInbox() async {
    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    final currentUserSnapshot = await FirebaseFirestore.instance.collection('users').doc(currentUserUid).get();

    if (!currentUserSnapshot.exists) return;

    final currentUser = UserModel.fromMap(currentUserSnapshot.data()!);

    if (Get.isRegistered<InboxController>()) {
      Get.find<InboxController>().addFollowPrompt(isReverse: true, user: currentUser);
    }
  }

  @override
  // TODO: implement userVideos
  RxList<VideoModel> userVideos = <VideoModel>[].obs;
}


        // await docRef.update({
        //   'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
        //   'likeCount': isLiked ? video.likeCount - 1 : video.likeCount + 1,
        // });

