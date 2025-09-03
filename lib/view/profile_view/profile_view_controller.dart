import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class ProfileViewController extends GetxController{
  FirebaseAuth auth = FirebaseAuth.instance;
  Rx<UserModel> user = UserModel.empty().obs;
  RxList<VideoModel> userVideos = <VideoModel>[].obs;
  RxBool isLoading = false.obs;
  RxInt totalLikes = 0.obs;
  RxInt totalComments = 0.obs;
  RxInt totalShares = 0.obs;
  var userName = ''.obs;

  @override
  void onInit() async {
    super.onInit();
    _getUserProfile();
  }

  Future<void> _getUserProfile() async {
     isLoading.value = true;
    try {
      final uid = await SharedPrefs.getUserId();
      print("user id fetched in profile controller: $uid");
      // FirebaseAuth.instance.currentUser!.uid;

      userName.value = await SharedPrefs.getUserName();

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      user.value = UserModel.fromMap(userDoc.data()!);

 
      final videoSnapshot = await FirebaseFirestore.instance
          .collection('videos')
          .where('uid', isEqualTo: uid)
          .get();

      print('Found videos: ${videoSnapshot.docs.length}');

      userVideos.value = videoSnapshot.docs
          .map((doc) => VideoModel.fromJson(doc.data(), doc.id))
          .toList();
      totalLikes.value = user.value.likes; 
       // userVideos.fold(0, (sum, video) => sum + (video.likeCount ?? 0));
    } catch (e) {
      Utils.snackBar("Error", "Failed to fetch user profile");
      print('Error in fetchUserProfile: $e');
    } finally {
      isLoading.value = false;
    }
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

}
