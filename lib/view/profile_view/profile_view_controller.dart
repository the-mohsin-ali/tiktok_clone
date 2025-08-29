import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';

class ProfileViewController extends GetxController{
  Rx<UserModel> user = UserModel.empty().obs;
  RxList<VideoModel> userVideos = <VideoModel>[].obs;
  RxBool isLoading = false.obs;
  RxInt totalLikes = 0.obs;
  RxString userName = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
     isLoading.value = true;
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      user.value = UserModel.fromMap(userDoc.data()!);

 
      final videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .get();

      userVideos.value = videoSnapshot.docs
          .map((doc) => VideoModel.fromJson(doc.data()))
          .toList();
      totalLikes.value =
         user.value.likes; 
          // userVideos.fold(0, (sum, video) => sum + (video.likeCount ?? 0));
    } catch (e) {
      Utils.snackBar("Error", "Failed to fetch user profile");
      print('Error in fetchUserProfile: $e');
    } finally {
      isLoading.value = false;
    }
  }

}
