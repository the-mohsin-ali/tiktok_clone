import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/services/shared_prefs.dart';

class PreviewScreenController extends GetxController {
  var isUploading = false.obs;

  Future<String?> getVideoUrl(String filePath) async {
    final uri = Uri.parse(
      "https://api.cloudinary.com/v1_1/dlvhzlppm/video/upload",
    );
    final request = MultipartRequest('POST', uri)
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
      print("Error: $e");
      return null;
    }
  }

  Future<bool> uploadAndSave(String filePath) async {
    try {
      isUploading.value = true;

      final videoUrl = await getVideoUrl(filePath);
      print("Value in videoUrl: $videoUrl");
      String? uid = await SharedPrefs.getUserId();
      print("Value in uid: $uid");
      String? profilePhoto = await SharedPrefs.getProfileUrl();
      print("Value in profilePhoto: $profilePhoto");
      if (videoUrl != null && uid != null) {
        VideoModel videoModel = VideoModel(
          videoUrl: videoUrl,
          uid: uid,
          profilePhoto: profilePhoto,
          uploadedAt: DateTime.now(), videoId: '',
        );

        await FirebaseFirestore.instance
            .collection("videos")
            .add(videoModel.toJson());

        // await FirebaseFirestore.instance.collection('users').doc(uid).update({
        //   'videosPosted' : FieldValue.arrayUnion([videoUrl]),
        //   'lastUploadTime' : DateTime.now()
        // });

        return true;
      }
    } catch (e) {
      print("Upload Error: $e");
    } finally {
      isUploading.value = false;
    }
    return false;
  }
}
