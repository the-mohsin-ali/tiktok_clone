import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_clone/models/user_model.dart';

class SharedPrefs {
  static const String userName = 'userName';
  static const String userId = 'userId';
  static const String userEmail = 'userEmail';
  static const String? profileUrl = 'profileUrl';
  static const String isLoggedIn = 'isLoggedIn';
  static late SharedPreferences sp;

  static String? cachedUid;

  static Future<void> initPrefs()async{
    sp = await SharedPreferences.getInstance();
    cachedUid = sp.getString('userId');
  }


  static Future<void> saveUserData(UserModel userModel) async {
    cachedUid = userModel.uid;

    final jsonString = jsonEncode(userModel.toMap());
    await sp.setString('user_model', jsonString);

    await sp.setBool(isLoggedIn, true);
    await sp.setString(userId, userModel.uid);

    // await sp.setString(userName, userModel.userName);
    // await sp.setString(userEmail, userModel.email);
    // await sp.setString(profileUrl, userModel.profilePhoto);
  }

  static Future<UserModel?> getUserFromPrefs() async {
    final jsonString = sp.getString('user_model');
    if(jsonString == null) return null;

    final jsonMap = jsonDecode(jsonString);
    return UserModel.fromMap(jsonMap);
  }

  static Future<String> getUserId() async{
    return sp.getString(userId) ?? '';
  }

  // static Future<String> getUserName() async{
  //   return sp.getString(userName) ?? '';
  // }
  // static Future<String> getUserEmail() async{
  //   return sp.getString(userEmail) ?? '';
  // }
  // static Future<String?> getProfileUrl() async{
  //   return sp.getString(profileUrl);
  // }

  static Future<bool?> getIsLoggedIn() async{
    return sp.getBool(isLoggedIn);
  }

  static Future<void> clearUserData() async {
    cachedUid = null;
    final success = await sp.clear();
    if(success){
      print("shared preferences clear successfully");
    }else{
      print("error clearing shared preference");
    }
  }
}