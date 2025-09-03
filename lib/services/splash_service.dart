import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/routes/routes_names.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class SplashService extends GetxController{
  void isLogin() async {
    bool isLoggedIn = await SharedPrefs.getIsLoggedIn() ?? false;
    // String? uid = await SharedPrefs.getUserId();
    User? currentUser = FirebaseAuth.instance.currentUser; 
    print('current user: $currentUser');
    print('is logged in: $isLoggedIn');
    
    await Future.delayed(Duration(seconds: 3));
    if(isLoggedIn && currentUser != null){
      Get.offAllNamed(RoutesNames.home);
    }else{
      Get.offAllNamed(RoutesNames.login);
    }
  }
}
