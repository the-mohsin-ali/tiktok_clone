import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/inbox_view/inbox_controller.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;

  final PageController pageController = PageController();

  RxList<VideoModel> videos = <VideoModel>[].obs;
  // final Rxn<UserModel> user = Rxn<UserModel>();

  final RxBool isFollowing = false.obs;

  // final List<VideoPlayerController> activeVideoControllers = [];

  @override
  void onInit() {
    super.onInit();
    print("onInit of home_controller called");

    _listenToVideosStream();
  }
  // @override
  // void onClose() {
  //   for (var controller in activeVideoControllers) {
  //     controller.dispose();
  //   }
  //   activeVideoControllers.clear();
  //   super.onClose();
  // }

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

  Future<void> _listenToVideosStream() async {
    try {
      FirebaseFirestore.instance.collection('videos').orderBy('uploadedAt', descending: true).snapshots().listen((
        snapshot,
      ) {
        videos.value = snapshot.docs.map((doc) => VideoModel.fromDocument(doc)).toList();
      });
      for (final video in videos) {
        checkIfFollowingForVideo(video);
      }
    } catch (e) {
      Utils.snackBar("Error", "Error listening to videos stream");
      print('Error listening to video stream');
    }
  }

  Future<void> fetchVideos() async {
    // isFetching = true;
    print("controllers fetch videos called");
    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('videos')
          .orderBy('uploadedAt', descending: true)
          .get();
      videos.clear();
      print('value in videos after videos.clear: ${videos.toString()}');
      videos.value = List.from(snapshot.docs.map((doc) => VideoModel.fromJson(doc.data(), doc.id)).toList());
      print("video url get in fetchVideos:${videos.value.first.videoUrl}");
      // videos.shuffle();
      update();
    } catch (e) {
      Utils.snackBar('Error', 'error fetching videos from database');
      print('error fetching videos from database: $e');
    } finally {
      isLoading.value = false;
      // isFetching = false;
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
}


        // await docRef.update({
        //   'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
        //   'likeCount': isLiked ? video.likeCount - 1 : video.likeCount + 1,
        // });

