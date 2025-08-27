import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
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

  @override
  void initState(){
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if(!cameraStatus.isGranted || !micStatus.isGranted){
      debugPrint("Permissions not granted");
      return;
    }

    _cameras = await availableCameras();

    if(_cameras != null && _cameras!.isNotEmpty){
      _cameraController = CameraController(_cameras![0], ResolutionPreset.high);
    }

    try{
      await _cameraController!.initialize();
      if(mounted) setState(() { _isInitialized = true; });
    }catch(e){
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> _startRecording() async {
    if(_cameraController == null || !_cameraController!.value.isInitialized) return;

    try{
      await _cameraController!.startVideoRecording();
      setState(() {
        _isRecording = true;
      });
    }catch(e){
      debugPrint("Error Starting video recording: $e");
    }
  }

  Future<void> _stopRecording() async {
    if(_cameraController == null || !_cameraController!.value.isRecordingVideo) return;

    try{
      XFile videoFile = await _cameraController!.stopVideoRecording();
      setState(() => _isRecording = false);
      Navigator.push(context, MaterialPageRoute(builder: (_)=> PreviewVideoScreen(videoPath: videoFile.path)));
    }catch(e){
      debugPrint("Error Stopping a video: $e");
    }
  }

  @override
  void dispose(){
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isInitialized ? Stack(
        children: [
          CameraPreview(_cameraController!),
          Align(
            alignment: AlignmentGeometry.bottomCenter,
            child: Padding(
              padding: EdgeInsetsGeometry.only(bottom: 30.h),
              child: FloatingActionButton(
                heroTag: 'create_view_fab',
                backgroundColor: _isRecording ? AppColor.buttonActiveColor : AppColor.secondaryColor,
                onPressed: _isRecording ? _stopRecording : _startRecording,
                child: Icon(_isRecording ? Icons.stop : Icons.videocam)
              ),
            ),
          )
        ],
      )
      : Center(child: CircularProgressIndicator(),),
    );
  }
}