import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class PreviewScreenController extends GetxController {
  var isUploading = false.obs;

  Future<String?> getVideoUrl(String filePath) async {
    try {
      final cloudName = 'dihv9cnmf';
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/video/upload");
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = 'user_videos'
        ..files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        final resJson = jsonDecode(resStr);
        print("cloudinary video link: ${resJson['secure_url']}");
        return resJson['secure_url'];
      } else {
        print("Cloudinary upload failed: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Cloudinary upload error: $e");
      return null;
    }
  }

  Future<bool> uploadAndSave({required String filePath, String? title, List<String>? keywords}) async {
    try {
      isUploading.value = true;

      // Step 1: Upload video
      final videoUrl = await getVideoUrl(filePath);
      if (videoUrl == null) return false;

      // Step 2: Get user info
      final uid = await SharedPrefs.getUserId();
      final userData = await SharedPrefs.getUserFromPrefs();
      if (uid == null || userData == null) return false;

      final userName = userData.userName;
      final profilePhoto = userData.profilePhoto;

      // Step 3: Create Firestore doc ref
      final docRef = FirebaseFirestore.instance.collection("videos").doc();

      // Step 4: Build model
      final videoModel = VideoModel.fromUserInput(
        videoId: docRef.id,
        videoUrl: videoUrl,
        uid: uid,
        userName: userName,
        profilePhoto: profilePhoto,
        title: title,
        description: null,
        keywords: keywords,
      );

      // Step 5: Save to Firestore
      await docRef.set(videoModel.toJson());

      return true;
    } catch (e) {
      print("Upload Error: $e");
      return false;
    } finally {
      isUploading.value = false;
    }
  }
}
