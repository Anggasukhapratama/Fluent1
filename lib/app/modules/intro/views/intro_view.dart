import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intro_controller.dart';

const Color kPrimaryColor = Color(0xFFFF6B35); // Oranye kemerahan

class IntroView extends GetView<IntroController> {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: controller.pageController,
            itemCount: controller.introData.length,
            onPageChanged: controller.onPageChanged,
            itemBuilder: (context, index) {
              final data = controller.introData[index];
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: IntroPage(
                  key: ValueKey(data["image"]),
                  image: data["image"]!,
                  description: data["description"]!,
                ),
              );
            },
          ),

          // Indikator PageView (Dots)
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.introData.length,
                  (index) => buildDot(index, controller.currentPage.value),
                ),
              ),
            ),
          ),

          // Tombol "Let's Go!"
          Obx(
            () =>
                controller.currentPage.value == controller.introData.length - 1
                    ? Positioned(
                      bottom: 30,
                      left: 60,
                      right: 60,
                      child: SizedBox(
                        width: 200,
                        height: 45,
                        child: ElevatedButton(
                          onPressed: () => Get.offAllNamed('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            elevation: 5,
                          ),
                          child: const Text(
                            "Let's Go!",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
          ),
        ],
      ),
    );
  }

  // Widget untuk indikator halaman (dots)
  Widget buildDot(int index, int currentPage) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: currentPage == index ? kPrimaryColor : Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

// Widget Halaman Intro
class IntroPage extends StatelessWidget {
  final String image;
  final String description;

  const IntroPage({super.key, required this.image, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Fluent",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: kPrimaryColor,
          ),
        ),
        const SizedBox(height: 24),
        Image.asset(image, width: 280, height: 280),
        const SizedBox(height: 32),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
