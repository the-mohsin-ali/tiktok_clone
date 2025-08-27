import 'package:shared_preferences/shared_preferences.dart';
import 'package:tiktok_clone/models/user_model.dart';

class SharedPrefs {
  static const String userName = 'userName';
  static const String userId = 'userId';
  static const String userEmail = 'userEmail';
  static const String profileUrl = 'profileUrl';
  static const String isLoggedIn = 'isLoggedIn';

  static Future<void> saveUserData(UserModel userModel) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(userId, userModel.uid);
    await sp.setString(userName, userModel.userName);
    await sp.setString(userEmail, userModel.email);
    await sp.setString(profileUrl, userModel.profilePhoto ?? '');
    await sp.setBool(isLoggedIn, true);
  }

  static Future<String?> getUserId() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userId);
  }
  static Future<String?> getUserName() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userName);
  }
  static Future<String?> getUserEmail() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(userEmail);
  }
  static Future<String?> getProfileUrl() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(profileUrl);
  }
  static Future<bool?> getIsLoggedIn() async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(isLoggedIn);
  }

  static Future<void> clearUserData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.clear();
  }
}