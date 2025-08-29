import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class HomeController extends GetxController {
  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;
  
  final PageController pageController = PageController();

  RxList<VideoModel> videos = <VideoModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    print("onInit of home_controller called");
    
    _listenToVideosStream();
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

  Future<void> _listenToVideosStream() async {
    try{
      FirebaseFirestore.instance.collection('videos').orderBy('uploadedAt', descending: true).snapshots().listen((snapshot){
        videos.value = snapshot.docs.map((doc) => VideoModel.fromDocument(doc)).toList();
      });
    }catch(e){
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
      videos.value = List.from(snapshot.docs.map((doc) => VideoModel.fromJson(doc.data())).toList());
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

  Future<void> addVideo(VideoModel video) async {
    isLoading.value = true;
    try {
      videos.insert(0, video);
    } catch (e) {
      Utils.snackBar("Error", "Error adding video to the top");
      print("Error adding video to the top");
    } finally {
      isLoading.value = false;
    }
  }
}
