import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraAnalysisController extends GetxController {
  CameraController? cameraController;
  var isRecording = false.obs;
  var isCameraInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  Future<void> initialize() async {
    await _requestPermissions();
    await _initializeCamera();
  }

  Future<void> _requestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (!cameraStatus.isGranted) {
      Get.snackbar("Akses Ditolak", "Izin kamera diperlukan");
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        Get.snackbar("Kamera Tidak Ditemukan", "Tidak ada kamera tersedia");
        return;
      }

      cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      print("Error inisialisasi kamera: $e");
      Get.snackbar("Gagal", "Tidak bisa inisialisasi kamera");
    }
  }

  Future<void> startAnalysis() async {
    isRecording.value = true;
    await Future.delayed(Duration(seconds: 10));
    isRecording.value = false;
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
