import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  Timer? _timer;

  // Data intro
  final List<Map<String, String>> introData = [
    {
      "image": "assets/images/intro1.png",
      "title": "Welcome to Fluent! 🚀",
      "description": "Tingkatin skill ngomong lo biar makin pede!",
    },
    {
      "image": "assets/images/intro2.png",
      "title": "Cepat & Efektif! ⏩",
      "description": "Latihan langsung pake AI, biar lo makin lancar ngomong.",
    },
    {
      "image": "assets/images/intro3.png",
      "title": "FLUENT pake Ai! 🤖",
      "description":
          "Cek ekspresi lo & dapetin feedback real-time biar makin jago!",
    },
  ];
  @override
  void onInit() {
    super.onInit();
    _startAutoScroll();
  }

  @override
  void onClose() {
    _timer?.cancel();
    pageController.dispose();
    super.onClose();
  }

  // Fungsi untuk auto-scroll
  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentPage.value < introData.length - 1) {
        currentPage.value++;
      } else {
        currentPage.value = 0;
      }
      pageController.animateToPage(
        currentPage.value,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  // Fungsi untuk mengubah halaman saat user swipe
  void onPageChanged(int index) {
    currentPage.value = index;
  }

  // Navigasi ke halaman login
  void navigateToLogin() {
    Get.offAllNamed('/login');
  }
}
