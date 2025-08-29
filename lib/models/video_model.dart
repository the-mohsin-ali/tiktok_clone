import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel{
  final String videoUrl;
  final String uid;
  final String? profilePhoto;
  final int likeCount;
  final List<String> likedBy;
  final int commentCount;
  final DateTime uploadedAt;

  VideoModel({required this.videoUrl, required this.uid, required this.profilePhoto, this.likeCount = 0, this.likedBy = const [], this.commentCount = 0, required this.uploadedAt});

  Map<String, dynamic> toJson(){
    return {
      "videoUrl" : videoUrl,
      "uid" : uid,
      "profilePhoto" : profilePhoto,
      "likeCount" : likeCount,
      "likedBy" : likedBy,
      "commentCount" : commentCount,
      "uploadedAt" : uploadedAt
    };
  }  

  factory VideoModel.fromJson(Map<String, dynamic> json){
    return VideoModel(videoUrl: json["videoUrl"], uid: json["uid"], profilePhoto: json["profilePhoto"], likeCount: json["likeCount"] ?? 0, likedBy: (json["likedBy"] as List?)?.map((e) => e.toString()).toList() ?? [], commentCount: json["commentCount"] ?? 0, uploadedAt: (json["uploadedAt"] as Timestamp).toDate());
  }

  factory VideoModel.fromDocument(DocumentSnapshot snapshot){
    final data = snapshot.data() as Map<String, dynamic>;
    return VideoModel(videoUrl: data['videoUrl'], uid: data['uid'], profilePhoto: data['profilePhoto'], uploadedAt: (data['uploadedAt'] as Timestamp).toDate(), commentCount: data['commentCount'], likeCount: data['likeCount'], likedBy: (data["likedBy"] as List?)?.map((e) => e.toString()).toList() ?? [],);
  }

}