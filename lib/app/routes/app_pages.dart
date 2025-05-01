import 'package:fluent/app/modules/hrd_simulation/controllers/hrd_simulation_controller.dart';
import 'package:get/get.dart';

import '../modules/aktivitas/bindings/aktivitas_binding.dart';
import '../modules/aktivitas/views/aktivitas_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/detection/bindings/detection_binding.dart';
import '../modules/detection/views/detection_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/hrd_simulation/bindings/hrd_simulation_binding.dart';
import '../modules/hrd_simulation/views/hrd_simulation_view.dart';
import '../modules/intro/bindings/intro_binding.dart';
import '../modules/intro/views/intro_view.dart';
import '../modules/lainnya/bindings/lainnya_binding.dart';
import '../modules/lainnya/views/lainnya_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.INTRO,
      page: () => IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: _Paths.DETECTION,
      page: () => DetectionView(),
      binding: DetectionBinding(),
    ),
    GetPage(
      name: _Paths.AKTIVITAS,
      page: () => const AktivitasView(),
      binding: AktivitasBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.HRD_SIMULATION,
      page: () => const HrdSimulationView(),
      binding: HrdSimulationBinding(),
    ),
    GetPage(
      name: _Paths.LAINNYA,
      page: () => const LainnyaView(),
      binding: LainnyaBinding(),
    ),
  ];
}
