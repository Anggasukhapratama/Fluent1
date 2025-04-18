import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_analysis_controller.dart';

class CameraAnalysisView extends StatelessWidget {
  final CameraAnalysisController controller = Get.put(
    CameraAnalysisController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deteksi Presentasi')),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            AspectRatio(
              aspectRatio: controller.cameraController!.value.aspectRatio,
              child: CameraPreview(controller.cameraController!),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  controller.isRecording.value
                      ? null
                      : controller.startAnalysis,
              child: Text(
                controller.isRecording.value
                    ? "Merekam..."
                    : "Mulai Rekam 10 Detik",
              ),
            ),
          ],
        );
      }),
    );
  }
}
