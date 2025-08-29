import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/create_view/preview/preview_screen.dart';

class CreateView extends StatefulWidget {
  const CreateView({super.key});

  @override
  State<CreateView> createState() => _CreateViewState();
}

class _CreateViewState extends State<CreateView> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isRecording = false;
  bool _isInitialized = false;
  bool _isDisposed = false;

  Timer? _timer;
  int _recordDuration = 0;
  String get _formattedTime {
    final minutes = (_recordDuration ~/ 60).toString().padLeft(2, '0');
    final seconds = (_recordDuration % 60).toString().padLeft(2, '0');
    return '$minutes : $seconds';
  }

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    await _cameraController?.dispose();
    _cameraController = null;

    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    print("camera permission status: $cameraStatus");
    print("mic permission status: $micStatus");

    if (!cameraStatus.isGranted || !micStatus.isGranted) {
      debugPrint("Permissions not granted");
      return;
    }

    _cameras = await availableCameras();

    // if (_cameraController != null) {
    //   await _cameraController!.dispose();
    // }

    if (_cameras != null && _cameras!.isNotEmpty) {
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
    }

    try {
      await _cameraController!.initialize();
      if (mounted && !_isDisposed) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> _startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
        _recordDuration = 0;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
        if (mounted) {
          setState(() {
            _recordDuration++;
          });
        }
      });
    } catch (e) {
      debugPrint("Error Starting video recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    if (_cameraController == null || !_cameraController!.value.isRecordingVideo) {
      return;
    }

    try {
      XFile videoFile = await _cameraController!.stopVideoRecording();
      _timer?.cancel();
      _timer = null;
      setState(() {
        _isRecording = false;
        _recordDuration = 0;
      });
      Navigator.push(context, MaterialPageRoute(builder: (_) => PreviewVideoScreen(videoPath: videoFile.path)));
    } catch (e) {
      debugPrint("Error Stopping a video: $e");
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized && _cameraController != null
          ? Stack(
              children: [
                CameraPreview(_cameraController!),
                Positioned(
                  top: 50.h,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: _isRecording
                        ? Container(
                            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10.r), backgroundBlendMode: BlendMode.darken),
                            child: Text(
                              _formattedTime,
                              style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                            ),
                          )
                        : const SizedBox(),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsetsGeometry.only(bottom: 30.h),
                    child: FloatingActionButton(
                      heroTag: 'create_view_fab',
                      backgroundColor: _isRecording ? AppColor.buttonActiveColor : AppColor.secondaryColor,
                      onPressed: _isRecording ? _stopRecording : _startRecording,
                      child: Icon(_isRecording ? Icons.stop : Icons.videocam),
                    ),
                  ),
                ),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
