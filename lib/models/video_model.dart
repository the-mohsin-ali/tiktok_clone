import 'package:cloud_firestore/cloud_firestore.dart';

class VideoModel {
  final String videoId;
  final String videoUrl;
  final String uid;
  final String? profilePhoto;
  final bool isFollowingThisPoster;
  final String userName;
  final String? videoTitle;
  final String? videoDescription;
  final int likeCount;
  final List<String> likedBy;
  final int commentCount;
  final int shareCount;
  final DateTime uploadedAt;
  final List<String>? keywords;

  VideoModel({
    required this.videoId,
    required this.videoTitle,
    required this.userName,
    this.videoDescription,
    this.shareCount = 0,
    required this.videoUrl,
    required this.uid,
    required this.profilePhoto,
    this.isFollowingThisPoster = false,
    this.likeCount = 0,
    this.likedBy = const [],
    this.commentCount = 0,
    required this.uploadedAt,
    this.keywords = const []
  });

  Map<String, dynamic> toJson() {
    return {
      "videoUrl": videoUrl,
      "videoTitle": videoTitle,
      "videoDescription": videoDescription,
      "uid": uid,
      "profilePhoto": profilePhoto,
      "userName": userName,
      "likeCount": likeCount,
      "likedBy": likedBy,
      "commentCount": commentCount,
      "shareCount": shareCount,
      "uploadedAt": uploadedAt,
      "keywords": keywords
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json, String videoId) {
    return VideoModel(
      videoId: videoId,
      videoUrl: json["videoUrl"],
      uid: json["uid"],
      profilePhoto: json["profilePhoto"],
      likeCount: json["likeCount"] ?? 0,
      likedBy: (json["likedBy"] as List?)?.map((e) => e.toString()).toList() ?? [],
      commentCount: json["commentCount"] ?? 0,
      shareCount: json["shareCount"] ?? 0,
      uploadedAt: (json["uploadedAt"] as Timestamp).toDate(),
      videoTitle: json["videoTitle"] ?? '',
      userName: json["userName"] ?? '',
      videoDescription: json['videoDescription'],
      keywords: (json["keywords"] as List?)?.map((e)=> e.toString()).toList() ?? [],
    );
  }


  factory VideoModel.fromUserInput({
  required String videoId,
  required String videoUrl,
  required String uid,
  required String userName,
  String? profilePhoto,
  String? title,
  String? description,
  List<String>? keywords,
}) {
  return VideoModel(
    videoId: videoId,
    videoUrl: videoUrl,
    uid: uid,
    profilePhoto: profilePhoto,
    userName: userName,
    videoTitle: title ?? "",
    videoDescription: description,
    uploadedAt: DateTime.now(),
    keywords: keywords ?? [],
  );
}


  factory VideoModel.fromDocument(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return VideoModel(
      videoId: snapshot.id,
      videoUrl: data['videoUrl'],
      uid: data['uid'],
      profilePhoto: data['profilePhoto'],
      uploadedAt: (data['uploadedAt'] as Timestamp).toDate(),
      commentCount: data['commentCount'] ?? 0,
      likeCount: data['likeCount'] ?? 0,
      likedBy: (data["likedBy"] as List?)?.map((e) => e.toString()).toList() ?? [],
      shareCount: data["shareCount"] ?? 0,
      videoTitle: data["videoTitle"] ?? '',
      userName: data["userName"] ?? '',
      videoDescription: data["videoDescription"],
      keywords: (data["keywords"] as List?)?.map((e)=> e.toString()).toList() ?? [],
    );
  }

  VideoModel copyWith({
    String? videoId,
    String? videoUrl,
    String? videoTitle,
    String? userName,
    String? uid,
    String? profilePhoto,
    bool? isFollowingThisPoster,
    int? likeCount,
    List<String>? likedBy,
    int? commentCount,
    int? shareCount,
    DateTime? uploadedAt,
  }) {
    return VideoModel(
      videoId: videoId ?? this.videoId,
      videoUrl: videoUrl ?? this.videoUrl,
      videoTitle: videoTitle ?? this.videoTitle,
      userName: userName ?? this.userName,
      uid: uid ?? this.uid,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      isFollowingThisPoster: isFollowingThisPoster ?? this.isFollowingThisPoster,
      likeCount: likeCount ?? this.likeCount,
      likedBy: likedBy ?? this.likedBy,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
