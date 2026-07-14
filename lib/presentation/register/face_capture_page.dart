import 'dart:io';
import 'package:camera/camera.dart';
import 'package:face_validator/models/live_face_result_model.dart';
import 'package:face_validator/presentation/register/face_overlay.dart';
import 'package:face_validator/services/face_detector_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceCapturePage extends StatefulWidget {
  /// Number of real photos to capture internally in one burst.
  final int totalShots;

  const FaceCapturePage({super.key, this.totalShots = 1});

  @override
  State<FaceCapturePage> createState() => _FaceCapturePageState();
}

class _FaceCapturePageState extends State<FaceCapturePage> {
  CameraController? _controller;
  bool _loading = true;
  LiveFaceResult _result = LiveFaceResult.initial();
  final faceDetectorService = FaceDetectorService();
  bool _processing = false;
  DateTime? _readySince;
  bool _autoCapturing = false;
  int _goodFrames = 0;

  bool _capturing = false;
  DateTime? _lastProcessedTime;
  static const _minFrameGap = Duration(milliseconds: 80);

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );
    _controller = CameraController(
      front,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21,
    );
    await _controller!.initialize();
    if (!mounted) return;
    await startImageStream();
    setState(() => _loading = false);
  }

  Future<void> startImageStream() async {
    if (_processing || _capturing || _disposed || !mounted) return;
    if (_controller == null) return;
    if (_controller!.value.isStreamingImages) return;

    await _controller!.startImageStream((CameraImage image) async {
      if (_processing || _capturing) return;

      final now = DateTime.now();
      if (_lastProcessedTime != null &&
          now.difference(_lastProcessedTime!) < _minFrameGap) {
        return;
      }
      _lastProcessedTime = now;
      _processing = true;

      try {
        final inputImage = _cameraImageToInputImage(image);
        if (inputImage == null) {
          _processing = false;
          return;
        }

        final result = await faceDetectorService.detectLiveFace(
          inputImage: inputImage,
          cameraImage: image,
          previewSize: _rotatedPreviewSize,
        );

        if (mounted && !_capturing && !_disposed) {
          setState(() => _result = result);
          await _handleAutoCapture();
        }
      } catch (e) {
        print('Error Ocurred: $e');
      }

      _processing = false;
    });
  }

  Size get _rotatedPreviewSize {
    final raw = _controller!.value.previewSize!;
    return Size(raw.height, raw.width);
  }

  InputImage? _cameraImageToInputImage(CameraImage image) {
    if (_controller == null) return null;
    final camera = _controller!.description;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation);
    if (rotation == null) return null;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final bytes = WriteBuffer();
    for (final plane in image.planes) {
      bytes.putUint8List(plane.bytes);
    }
    final byteData = bytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: byteData,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    _controller?.stopImageStream().catchError((_) {});
    _controller?.dispose();
    faceDetectorService.dispose();
    super.dispose();
  }

  Future<void> captureBurst() async {
    if (_controller == null || _capturing) return;
    _capturing = true;

    final List<File> files = [];

    try {
      var waited = 0;
      while (_processing && waited < 1000) {
        await Future.delayed(const Duration(milliseconds: 20));
        waited += 20;
      }

      await _controller!.stopImageStream();
      await Future.delayed(const Duration(milliseconds: 100));

      if (mounted) {
        setState(() => _result = _result.copyWith(message: "Capturing..."));
      }

      for (int i = 0; i < widget.totalShots; i++) {
        if (i > 0) {
          await Future.delayed(const Duration(milliseconds: 120));
        }
        final XFile file = await _controller!.takePicture();
        files.add(File(file.path));

        if (mounted) {
          setState(() {
            _result = _result.copyWith(
              message: i < widget.totalShots - 1 ? "Capturing..." : "Done!",
            );
          });
        }
      }

      if (!mounted) return;
      Navigator.pop(context, files);
    } catch (e) {
      debugPrint('captureBurst failed: $e');
      _capturing = false;
      if (mounted) {
        await startImageStream();
      }
    }
  }

  Future<void> _handleAutoCapture() async {
    if (_autoCapturing || _capturing) return;

    if (!_result.readyToCapture) {
      _readySince = null;
      _goodFrames = 0;
      return;
    }

    _goodFrames++;
    if (_goodFrames < 2) return;

    _readySince ??= DateTime.now();
    final elapsed = DateTime.now().difference(_readySince!);

    if (mounted && elapsed.inMilliseconds < 300) {
      setState(() => _result = _result.copyWith(message: "Hold Still..."));
      return;
    }

    _autoCapturing = true;
    await captureBurst();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          FaceOverlay(isValid: _result.hasSingleFace),
          Positioned(
            bottom: 140,
            left: 20,
            right: 20,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _result.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    if (_readySince != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: SizedBox(
                          width: 170,
                          child: LinearProgressIndicator(
                            value: (DateTime.now().difference(_readySince!).inMilliseconds / 300)
                                .clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 45,
            left: 20,
            child: SafeArea(
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}