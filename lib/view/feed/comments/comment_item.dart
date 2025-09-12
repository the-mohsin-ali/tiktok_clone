import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path/path.dart';
import 'package:tiktok_clone/models/comments_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatelessWidget  {
  final CommentsModel model;
  final VoidCallback onLike;
  final VoidCallback onReply;
  // final VoidCallback onViewReplies;
  final String videoId;
  final bool isLiked;
  final int replyCount;

  const CommentItem({
    super.key,
    required this.model,
    required this.videoId,
    this.isLiked = false,
    required this.onReply,
    // required this.onViewReplies,
    required this.onLike,
    this.replyCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    // final controller = Get.find<CommentsController>();
    // final currentUid =  SharedPrefs.cachedUid;
    // final isLiked = controller.
    final timeAgo = timeago.format(model.uploadedAt, locale: 'en_short').replaceAll('~', '');
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: model.avatarUrl != null && model.avatarUrl!.isNotEmpty
                    ? NetworkImage(model.avatarUrl!)
                    : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        style: TextStyle(fontSize: 13.sp, color: Colors.white),
                        children: [
                          TextSpan(
                            text: '${model.userName}\n',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(text: model.comment),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        // Wrap left-side (timeAgo + Reply) in Expanded
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                timeAgo,
                                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                              ),
                              SizedBox(width: 12.w),
                              GestureDetector(
                                onTap: onReply,
                                child: Text(
                                  "Reply",
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Right-side: Like button
                        GestureDetector(
                          onTap: onLike,
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                color: isLiked ? Colors.red : Colors.grey,
                                size: 16.sp,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${model.likedBy.length}',
                                style: TextStyle(color: Colors.grey, fontSize: 11.sp),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          // if (!model.isReply && replyCount > 0) ...[
          //   SizedBox(height: 6.h),
          //   GestureDetector(
          //     onTap: onViewReplies,
          //     child: Padding(
          //       padding: EdgeInsets.only(left: 46.w),
          //       child: Text(
          //         'View $replyCount ${replyCount == 1 ? 'reply' : 'replies'}',
          //         style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          //       ),
          //     ),
          //   ),
          // ],
        ],
      ),
    );
  }
}
