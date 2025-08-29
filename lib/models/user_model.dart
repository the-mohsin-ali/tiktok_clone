class UserModel {
  final String uid;
  final String email;
  final String userName;
  final String? profilePhoto;
  final List<String> followers;
  final List<String> following;
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
      'followers': followers,
      'following': following,
      'likes': likes,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'],
      email: map['email'],
      userName: map['userName'],
      profilePhoto: map['profilePhoto'],
      followers: List<String>.from(map['followers'] ?? []),
      following: List<String>.from(map['following'] ?? []),
      likes: map['likes'] ?? 0,
    );
  }

  int get followersCount => followers.length;
  int get followingCount => following.length;
}
