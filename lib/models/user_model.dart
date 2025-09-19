import 'package:tiktok_clone/models/follow_user_model.dart';

class UserModel {
  final String uid;
  final String email;
  final String userName;
  final String? profilePhoto;
  final List<FollowUserModel> followers;
  final List<FollowUserModel> following;
  final int likes;

  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
    this.profilePhoto,
    required this.followers,
    required this.following,
    required this.likes,
  });

  factory UserModel.empty() {
    return UserModel(uid: '', email: '', userName: '', profilePhoto: '', followers: [], following: [], likes: 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'userName': userName,
      'profilePhoto': profilePhoto,
      'followers': followers.map((f) => f.toMap()).toList(),
      'following': following.map((f) => f.toMap()).toList(),
      'likes': likes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      userName: map['userName'],
      profilePhoto: map['profilePhoto'],
      followers: (map['followers'] as List<dynamic>? ?? [])
          .map((f) => FollowUserModel.fromMap(f as Map<String, dynamic>))
          .toList(),
      following: (map['following'] as List<dynamic>? ?? [])
          .map((f) => FollowUserModel.fromMap(f as Map<String, dynamic>))
          .toList(),
      likes: map['likes'] ?? 0,
    );
  }

  int get followersCount => followers.length;
  int get followingCount => following.length;
}
