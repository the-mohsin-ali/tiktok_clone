class CommentsModel {
  final String commentId;
  final String avatarUrl;
  final String userName;
  final String comment;
  final int commentLikeCount;
  final DateTime uploadedAt;

  CommentsModel({required this.commentId, required this.avatarUrl, required this.userName, this.commentLikeCount = 0, required this.comment, required this.uploadedAt});

  Map<String, dynamic> toJson(){
    return{
      'comment' :  comment,
      'avatarUrl' : avatarUrl,
      'userName' : userName,
      'uploadedAt' : uploadedAt
    };
  }

  factory CommentsModel.fromJson(Map<String, dynamic> json, String commentId){
    return CommentsModel(commentId: commentId, comment: json['comment'], uploadedAt: json['uploadedAt'], avatarUrl: json['avatarUrl'], userName: json['userName']);
  }
}