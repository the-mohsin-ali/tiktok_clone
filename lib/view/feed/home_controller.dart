import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class HomeController extends GetxController{

  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;

  RxList<VideoModel> videos = <VideoModel>[].obs;

  @override
  void onInit(){
    super.onInit();
    _fetchVideos();
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

  Future<void> _fetchVideos() async {
    isLoading.value = true;
    try{
      final snapshot = await FirebaseFirestore.instance.collection('videos').orderBy('uploadedAt').get();
      videos.value = snapshot.docs.map((doc)=> VideoModel.fromJson(doc.data())).toList();
    }catch(e){
      Utils.snackBar('Error', 'error fetching videos from database');
      print('error fetching videos from database: $e');
    }finally{
      isLoading.value = false;
    }
  }
}