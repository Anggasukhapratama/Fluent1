import 'package:get/get.dart';

import '../controllers/camera_analysis_controller.dart';

class CameraAnalysisBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CameraAnalysisController>(
      () => CameraAnalysisController(),
    );
  }
}
