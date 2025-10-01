import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/models/comments_model.dart';
import 'package:tiktok_clone/models/video_model.dart';
import 'package:tiktok_clone/view/feed/comments/comment_item.dart';
import 'package:tiktok_clone/view/feed/comments/comments_controller.dart';

class CommentsBottomsheet extends StatefulWidget {
  final VideoModel video;
  final ScrollController? scrollController;

  const CommentsBottomsheet({super.key, required this.video, this.scrollController});

  @override
  State<CommentsBottomsheet> createState() => _CommentsBottomsheetState();
}

class _CommentsBottomsheetState extends State<CommentsBottomsheet> {
  late final CommentsController controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initComments(widget.video.videoId);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _focusNode.unfocus(),
      child: Column(
        children: [
          // 👇 drag handle (optional)
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: Column(
              children: [
                CommentsList(
                  controller: controller,
                  videoId: widget.video.videoId,
                  scrollController: widget.scrollController,
                ),
                ReplyWidget(controller: controller),
                BottomTextField(controller: controller, videoId: widget.video.videoId, focusNode: _focusNode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BottomTextField extends StatelessWidget {
  const BottomTextField({super.key, required this.controller, required this.videoId, required this.focusNode});

  final CommentsController controller;
  final String videoId;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            children: [
              Obx(() {
                final avatarUrl = controller.profileUrl?.value ?? '';
                return SizedBox(
                  width: 32.w,
                  height: 32.w,
                  child: CircleAvatar(
                    backgroundColor: AppColor.secondaryColor,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : const AssetImage('assets/images/default_profile.jpg') as ImageProvider,
                  ),
                );
              }),
              SizedBox(width: 8.w),
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  focusNode: focusNode,
                  textInputAction: TextInputAction.send,
                  maxLines: null,
                  minLines: 1,
                  onSubmitted: (_) => _handleSubmit(),
                  decoration: InputDecoration(
                    hintText: 'Add Comment...',
                    filled: true,
                    fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800] : Colors.grey[200],
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Obx(() {
                final isActive = controller.isFormFilled.value;
                return InkWell(
                  onTap: isActive ? _handleSubmit : null,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: EdgeInsets.all(4.w),
                    child: Image.asset(
                      'assets/icons/send_icon.png',
                      height: 25.h,
                      width: 25.w,
                      color: isActive ? AppColor.buttonActiveColor : AppColor.buttonInactiveColor,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSubmit() {
    final replyingTo = controller.replyingTo.value;
    if (replyingTo != null) {
      controller.addReply(videoId, replyingTo.commentId);
    } else {
      controller.addComment(videoId);
    }
    controller.cancelReply();
    focusNode.unfocus();
  }
}

class CommentsList extends StatelessWidget {
  const CommentsList({super.key, required this.controller, required this.videoId, this.scrollController});

  final CommentsController controller;
  final String videoId;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final comments = controller.comments;

      return Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(alignment: Alignment.center, child: Text('${comments.length} comments')),
            SizedBox(height: 10.h),
            Expanded(
              child: comments.isEmpty
                  ? const Center(child: Text("No comments yet."))
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView.builder(
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        itemCount: comments.length,
                        cacheExtent: 500,
                        itemBuilder: (context, index) {
                          final comment = comments[index];
                          if (comment.isReply) return const SizedBox.shrink();

                          return _CommentWithReplies(comment: comment, controller: controller, videoId: videoId);
                        },
                      ),
                    ),
            ),
          ],
        ),
      );
    });
  }
}

class _CommentWithReplies extends StatelessWidget {
  const _CommentWithReplies({required this.comment, required this.controller, required this.videoId});

  final CommentsModel comment;
  final CommentsController controller;
  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Parent Comment
          CommentItem(
            model: comment,
            videoId: videoId,
            onReply: () => controller.startReplyTo(comment),
            onLike: () => controller.likeComment(videoId, comment.commentId),
          ),

          // Replies with fixed indent
          if (comment.repliesStream != null)
            StreamBuilder<List<CommentsModel>>(
              stream: controller.getReplies(videoId, comment.commentId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const SizedBox.shrink();

                final replies = snapshot.data!;

                return Column(
                  children: replies.map((reply) {
                    return Padding(
                      padding: EdgeInsets.only(left: 46.w, top: 4),
                      child: CommentItem(
                        model: reply,
                        videoId: videoId,
                        onReply: () => controller.startReplyTo(reply),
                        onLike: () => controller.likeComment(videoId, reply.commentId),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
        ],
      ),
    );
  }
}

class ReplyWidget extends StatelessWidget {
  const ReplyWidget({super.key, required this.controller});

  final CommentsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final replyTo = controller.replyingTo.value;
      if (replyTo == null) return const SizedBox.shrink();

      return AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        margin: EdgeInsets.only(bottom: 8.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey.withAlpha(50)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Replying to @${replyTo.userName}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColor.secondaryColor
                      : AppColor.primaryColor,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.cancelReply,
              child: Icon(Icons.close, size: 16.sp, color: Colors.grey),
            ),
          ],
        ),
      );
    });
  }
}
