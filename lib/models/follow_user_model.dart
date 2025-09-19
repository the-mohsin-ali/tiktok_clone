class FollowUserModel {
  final String uid;
  final String profilePhoto;
  final String userName;

  FollowUserModel({required this.uid, required this.profilePhoto, required this.userName});

  Map<String, dynamic> toMap(){
    return{
      'uid': uid,
      'profilePhoto': profilePhoto,
      'userName': userName
    };
  }

  factory FollowUserModel.fromMap(Map<String, dynamic> map){
    return FollowUserModel(uid: map['uid'], profilePhoto: map['profilePhoto'], userName: map['userName']);
  }
}