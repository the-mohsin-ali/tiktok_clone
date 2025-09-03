import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/view/profile_view/video_details/video_details_view.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoGridItem extends StatefulWidget {
  final String videoUrl;
  final int index;
  const VideoGridItem({super.key, required this.videoUrl, required this.index});

  @override
  State<VideoGridItem> createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  Uint8List? _thumbnailBytes;

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  Future<void> _loadThumbnails() async {
    final thumb = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 120,
      quality: 75,
    );

    if (mounted) {
      setState(() {
        _thumbnailBytes = thumb;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => VideoDetailsView(initialIndex: widget.index));
      },
      child: _thumbnailBytes != null
          ? Stack(
              fit: StackFit.expand,
              children: [
                Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Icon(Icons.play_circle_fill, color: Colors.white),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
