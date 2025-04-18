import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/detection_controller.dart';

class DetectionView extends StatelessWidget {
  const DetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetectionController());

    return Scaffold(
      appBar: AppBar(title: const Text('Analisis Real-Time')),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // Memperbesar frame kamera
            Expanded(child: CameraPreview(controller.cameraController)),
            const SizedBox(height: 16),
            // Menampilkan hasil analisis
            Text(controller.result.value, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            // Tombol untuk mulai latihan
            ElevatedButton(
              onPressed: controller.startRealTimeAnalysis,
              child: const Text('Mulai Latihan'),
            ),
            const SizedBox(height: 16),
            // Tombol untuk ganti kamera
            ElevatedButton.icon(
              onPressed: controller.switchCamera,
              icon: const Icon(Icons.cameraswitch),
              label: const Text('Ganti Kamera'),
            ),
            const SizedBox(height: 16),
          ],
        );
      }),
    );
  }
}
