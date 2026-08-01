import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewScreen extends StatefulWidget {
  final File file;
  const MediaPreviewScreen({required this.file, super.key});

  @override
  State<MediaPreviewScreen> createState() => _MediaPreviewScreenState();
}

class _MediaPreviewScreenState extends State<MediaPreviewScreen> {
  VideoPlayerController? _videoController;
  bool get isVideo => widget.file.path.endsWith('.mp4') || widget.file.path.endsWith('.mov');

  @override
  void initState() {
    super.initState();
    if (isVideo) {
      _videoController = VideoPlayerController.file(widget.file)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: isVideo
                  ? (_videoController?.value.isInitialized ?? false)
                        ? AspectRatio(
                            aspectRatio: _videoController!.value.aspectRatio,
                            child: VideoPlayer(_videoController!),
                          )
                        : CircularProgressIndicator()
                  : Image.file(widget.file),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text("Send")),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
