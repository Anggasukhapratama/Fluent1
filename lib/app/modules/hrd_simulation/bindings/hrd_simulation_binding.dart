import 'package:get/get.dart';

import '../controllers/hrd_simulation_controller.dart';

class HrdSimulationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HrdSimulationController>(() => HrdSimulationController());
  }
}
