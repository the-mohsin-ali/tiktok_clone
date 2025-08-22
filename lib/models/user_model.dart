class UserModel {
  final String uid;
  final String email;
  final String userName;
  final String? profilePhoto;

  UserModel({
    required this.uid,
    required this.email,
    required this.userName,
    this.profilePhoto,
  });
  Map<String, dynamic> toMap(){
    return{
      'uid' : uid,
      'email' : email,
      'userName' : userName,
      'profilePhoto' : profilePhoto,
    };
  }
  factory UserModel.fromMap(Map<String, dynamic> map){
    return UserModel(uid: map['uid'], email: map['email'], userName: map['userName'], profilePhoto: map['profilePhoto']);
  }

}