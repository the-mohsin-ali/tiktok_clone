import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tiktok_clone/constants/widgets/video_thumbnail.dart';
import 'package:tiktok_clone/models/enumns.dart';
import 'package:tiktok_clone/models/message_model.dart';
import 'package:tiktok_clone/models/user_model.dart';
import 'package:tiktok_clone/view/inbox_view/chat/fullscreen_image_viewer.dart';
import 'package:tiktok_clone/view/inbox_view/chat/fullscreen_video_viewer.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMe;
  final bool isGroup;
  final UserModel? sender;

  const MessageBubble({super.key, required this.message, required this.isMe, required this.isGroup, this.sender});

  @override
  Widget build(BuildContext context) {
    final bubbleColor = isMe ? Colors.blue[400] : Colors.grey[200];
    final textColor = isMe ? Colors.white : Colors.black87;

    Widget content;

    switch (message.messageType) {
      case MessageType.text:
        content = Text(message.text, style: TextStyle(fontSize: 15, color: textColor));
        break;

      case MessageType.image:
        content = GestureDetector(
          onTap: () {
            // showDialog(
            //   context: context,
            //   builder: (_) => Dialog(
            //     insetPadding: EdgeInsets.all(16),
            //     child: InteractiveViewer(
            //       child: Image.network(
            //         message.mediaUrl ?? '',
            //         fit: BoxFit.contain,
            //         errorBuilder: (_, __, ___) => const Center(child: Text('Failed to load image')),
            //       ),
            //     ),
            //   ),
            // );
            if (message.mediaUrl != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullscreenImageViewer(imageUrl: message.mediaUrl!),
          ),
        );
      }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              message.mediaUrl ?? '',
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Text('Failed to load image', style: TextStyle(color: textColor)),
            ),
          ),
        );
        break;

      case MessageType.video:
        content = VideoThumbnail(url: message.mediaUrl ?? '');
        break;

      default:
        content = Text('[Unsupported]', style: TextStyle(fontSize: 15, color: textColor));
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isMe && isGroup && sender != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  sender!.userName,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                ),
              ),

            // ✅ Video keeps its special gesture detector
            if (message.messageType == MessageType.video && message.mediaUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => FullscreenVideoViewer(videoUrl: message.mediaUrl!)),
                  );
                },
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black12,
                        child: Center(child: Icon(Icons.play_circle_fill, size: 50, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              )
            else
              // ✅ Images + text come from the switch-case
              content,

            const SizedBox(height: 6),
            Text(
              message.createdAt != null ? DateFormat('hh:mm a').format(message.createdAt!) : '...',
              style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
