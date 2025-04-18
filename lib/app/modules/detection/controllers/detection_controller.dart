import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class DetectionController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  RxBool isCameraInitialized = false.obs;
  RxString result = "Menunggu analisis...".obs;
  Timer? _timer;
  RxInt selectedCameraIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    // Ambil daftar kamera yang tersedia
    cameras = await availableCameras();
    final camera = cameras[selectedCameraIndex.value];

    // Inisialisasi camera controller
    cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;
  }

  // Fungsi untuk mengganti kamera (depan/belakang)
  Future<void> switchCamera() async {
    isCameraInitialized.value = false;
    selectedCameraIndex.value =
        (selectedCameraIndex.value + 1) % cameras.length;

    // Inisialisasi kamera yang baru
    cameraController = CameraController(
      cameras[selectedCameraIndex.value],
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;
  }

  // Fungsi untuk memulai analisis real-time
  void startRealTimeAnalysis() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!cameraController.value.isInitialized ||
          cameraController.value.isTakingPicture)
        return;

      try {
        final XFile file = await cameraController.takePicture();
        final bytes = await File(file.path).readAsBytes();
        final base64Image = base64Encode(bytes);

        final response = await http.post(
          Uri.parse(
            "http://192.168.167.186:5000/analyze_realtime", // Ganti IP sesuai server Flask
          ),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({"frame": base64Image}),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          result.value =
              "Emosi: ${data['emotion']}\nMulut: ${data['mouth']}\nPostur: ${data['pose']}";
        } else {
          result.value = "Gagal analisis: ${response.body}";
        }
      } catch (e) {
        result.value = "Error: $e";
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    cameraController.dispose();
    super.onClose();
  }
}
