import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoGridItem extends StatefulWidget {
  final String videoUrl;

  const VideoGridItem({super.key, required this.videoUrl});

  @override
  State<VideoGridItem> createState() => _VideoGridItemState();
}

class _VideoGridItemState extends State<VideoGridItem> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        // Set to loop and mute (optional)
        _controller.setLooping(true);
        _controller.setVolume(0);
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? GestureDetector(
            onTap: () {
             
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Icon(Icons.play_circle_fill, color: Colors.white),
                ),
              ],
            ),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
