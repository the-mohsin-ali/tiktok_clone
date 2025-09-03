import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/video_model.dart';

class HomeController extends GetxController {
  RxBool isLoading = false.obs;

  final PageController pageController = PageController();

  RxList<VideoModel> videos = <VideoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("onInit of home_controller called");

    _listenToVideosStream();
  }

  Future<void> _listenToVideosStream() async {
    try {
      FirebaseFirestore.instance.collection('videos').orderBy('uploadedAt', descending: true).snapshots().listen((
        snapshot,
      ) {
        videos.value = snapshot.docs.map((doc) => VideoModel.fromDocument(doc)).toList();
      });
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
      try {
        await docRef.update({
          'likedBy': isLiked ? FieldValue.arrayRemove([currentUid]) : FieldValue.arrayUnion([currentUid]),
          'likeCount': isLiked ? video.likeCount - 1 : video.likeCount + 1,
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
