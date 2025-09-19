import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/interfaces/video_list_controller.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class ProfileViewController extends GetxController implements VideoListController {
  FirebaseAuth auth = FirebaseAuth.instance;
  Rx<UserModel> user = UserModel.empty().obs;
  RxList<VideoModel> userVideos = <VideoModel>[].obs;
  RxBool isLoading = false.obs;
  RxInt totalLikes = 0.obs;
  RxInt followingCount = 0.obs;
  RxInt followersCount = 0.obs;
  var userName = ''.obs;

  final String? currentUid = FirebaseAuth.instance.currentUser?.uid;

  // final List<VideoPlayerController> activeVideoControllers = [];

  @override
  void onInit() async {
    super.onInit();
    _getUserProfile();
    listenFollowersCount(currentUid!);
    listenFollowingCount(currentUid!);
  }

  // void register(VideoPlayerController controller) {
  //   activeVideoControllers.add(controller);
  // }

  // void pauseAllVideos() {
  //   for (var controller in activeVideoControllers) {
  //     if (controller.value.isPlaying) controller.pause();
  //   }
  // }

  // void resumeAllVideos() {
  //   for (var controller in activeVideoControllers) {
  //     if (!controller.value.isPlaying) controller.play();
  //   }
  // }

  // @override
  // void onClose() {
  //   for (var controller in activeVideoControllers) {
  //     controller.dispose();
  //   }
  //   activeVideoControllers.clear();
  //   super.onClose();
  // }

  Future<void> _getUserProfile() async {
    isLoading.value = true;
    try {
      final uid = await SharedPrefs.getUserId();
      print("user id fetched in profile controller: $uid");
      // FirebaseAuth.instance.currentUser!.uid;

      final userData = await SharedPrefs.getUserFromPrefs();

      if (userData != null) {
        userName.value = userData.userName;
      }

      FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((snapshot) {
        if (snapshot.exists) {
          user.value = UserModel.fromMap(snapshot.data()!);
          totalLikes.value = snapshot['likes'] ?? 0;
        }
      });

      final videoSnapshot = await FirebaseFirestore.instance.collection('videos').where('uid', isEqualTo: uid).get();

      print('Found videos: ${videoSnapshot.docs.length}');

      userVideos.value = videoSnapshot.docs.map((doc) => VideoModel.fromJson(doc.data(), doc.id)).toList();
      totalLikes.value = user.value.likes;
      print("userVideos contains totalLikes: ${totalLikes.value}");
      print("userVideos at index 0 contains isLikedBy: ${userVideos[0].likedBy}");
      // userVideos.fold(0, (sum, video) => sum + (video.likeCount ?? 0));
    } catch (e) {
      Utils.snackBar("Error", "Failed to fetch user profile");
      print('Error in fetchUserProfile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void listenFollowersCount(String targetUid) {
    FirebaseFirestore.instance.collection('users').doc(targetUid).collection('followers').snapshots().listen((snap) {
      followersCount.value = snap.docs.length;
    });
  }

  void listenFollowingCount(String targetUid) {
    FirebaseFirestore.instance.collection('users').doc(targetUid).collection('following').snapshots().listen((snap) {
      followingCount.value = snap.docs.length;
    });
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      await auth.signOut();
      await SharedPrefs.clearUserData();
      Get.offAllNamed(RoutesNames.login);
    } catch (e) {
      print('Error: $e');
      Utils.snackBar('Error', 'Failed to logout: $e');
    } finally {
      isLoading.value = false;
    }
  }

  final Map<String, Timer> _debounceTimers = {};

  Future<void> addLike(VideoModel video) async {
    final videoId = video.videoId;

    final currentUid = FirebaseAuth.instance.currentUser!.uid;
    final isLiked = video.likedBy.contains(currentUid);

    int index = userVideos.indexWhere((v) => v.videoId == videoId);
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
      userVideos[index] = video.copyWith(likedBy: updatedLikedBy, likeCount: updatedLikeCount);
      userVideos.refresh(); // Force UI update
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
}
