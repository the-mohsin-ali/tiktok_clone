import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoplayerItem extends StatefulWidget {
  final String videoUrl;
  const VideoplayerItem({super.key, required this.videoUrl});

  @override
  State<VideoplayerItem> createState() => _VideoplayerItemState();
}

class _VideoplayerItemState extends State<VideoplayerItem> {

  late VideoPlayerController _controller;

  @override
  void initState(){
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
    ..initialize().then((_){
      setState(() {});
      _controller.play();
      _controller.setLooping(true);
    });
  }

  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
    ? SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.size.width,
          height: _controller.value.size.height,
          child: VideoPlayer(_controller),
        ),
      ),
    )
    : Center(child: CircularProgressIndicator(),);
  }
}