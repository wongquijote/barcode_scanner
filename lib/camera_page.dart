import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  List<CameraDescription>? cameras;
  late CameraDescription firstCamera;
  bool isCameraInitialized = false;
  File? imageFile;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras!.first;

    controller = CameraController(firstCamera, ResolutionPreset.high);

    await controller!.initialize();
    setState(() {
      isCameraInitialized = true;
    });
  }

  Future<void> takePicture() async {
    if (!controller!.value.isInitialized) {
      return;
    }
    if (controller!.value.isTakingPicture) {
      return;
    }

    try {
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String pictureDirectory = '${appDirectory.path}/Pictures';
      await Directory(pictureDirectory).create(recursive: true);
      final String filePath = join(pictureDirectory, '${DateTime.now()}.png');

      await controller!.takePicture();
      setState(() {
        imageFile = File(filePath);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera App'),
      ),
      body: isCameraInitialized
          ? Column(
              children: [
                AspectRatio(
                  aspectRatio: controller!.value.aspectRatio,
                  child: CameraPreview(controller!),
                ),
                ElevatedButton(
                  onPressed: takePicture,
                  child: Text('Take Picture'),
                ),
                if (imageFile != null) Image.file(imageFile!),
              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
