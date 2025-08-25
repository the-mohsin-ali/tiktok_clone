import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/constants/utils/utils.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class HomeController extends GetxController{

  FirebaseAuth auth = FirebaseAuth.instance;
  RxBool isLoading = false.obs;

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