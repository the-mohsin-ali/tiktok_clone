import 'package:cloud_firestore/cloud_firestore.dart';

class CommentsModel {
  final String commentId;
  final String? avatarUrl;
  final String userName;
  final String comment;
  final bool isReply;
  final String? parentCommentId;
  final int commentLikeCount;
  final List<String> likedBy;
  final DateTime uploadedAt;

  CommentsModel({
    required this.commentId,
    this.avatarUrl,
    required this.userName,
    this.commentLikeCount = 0,
    required this.likedBy,
    required this.comment,
    this.isReply = false,
    this.parentCommentId,
    required this.uploadedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'comment': comment,
      'avatarUrl': avatarUrl,
      'userName': userName,
      'commentLikeCount': commentLikeCount,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'isReply': isReply,
      'parentCommentId': parentCommentId,
      'likedBy': likedBy,
    };
  }

  factory CommentsModel.fromJson(Map<String, dynamic> json, String commentId) {
    return CommentsModel(
      commentId: commentId,
      comment: json['comment'],
      uploadedAt: (json['uploadedAt'] as Timestamp).toDate(),
      commentLikeCount: (json['commentLikeCount'] ?? 0) as int,
      isReply: json['isReply'] ?? false,
      parentCommentId: json['parentCommentId'],
      likedBy: List<String>.from(json['likedBy'] ?? []),
      avatarUrl: json['avatarUrl'],
      userName: json['userName'],
    );
  }

  CommentsModel copyWith({
    String? commentId,
    String? avatarUrl,
    String? userName,
    String? comment,
    DateTime? uploadedAt,
    int? commentLikeCount,
    bool? isReply,
    String? parentCommentId,
    List<String>? likedBy,
  }) {
    return CommentsModel(
      commentId: commentId ?? this.commentId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      userName: userName ?? this.userName,
      comment: comment ?? this.comment,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      commentLikeCount: commentLikeCount ?? this.commentLikeCount,
      isReply: isReply ?? this.isReply,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      likedBy: likedBy ?? this.likedBy,
    );
  }
}
