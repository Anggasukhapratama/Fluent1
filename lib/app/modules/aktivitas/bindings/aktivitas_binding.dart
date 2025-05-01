import 'package:get/get.dart';

import '../controllers/aktivitas_controller.dart';

class AktivitasBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AktivitasController>(
      () => AktivitasController(),
    );
  }
}
