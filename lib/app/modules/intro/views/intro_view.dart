import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/intro_controller.dart';

const Color kPrimaryColor = Color(0xFFFF6B35); // Oranye kemerahan

class IntroView extends GetView<IntroController> {
  final PageController _pageController = PageController();

  final List<Map<String, String>> introData = [
    {
      "image": "assets/images/intro1.png",
      "text":
          "Fluent membantumu melakukan simulasi wawancara & presentasi secara cerdas.",
    },
    {
      "image": "assets/images/intro2.png",
      "text":
          "Deteksi ekspresi wajah, postur tubuh, dan intonasi suara secara real-time.",
    },
    {
      "image": "assets/images/intro3.png",
      "text":
          "Tingkatkan rasa percaya diri & tampil maksimal bersama teknologi AI Fluent.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: introData.length,
            onPageChanged: controller.setPage,
            itemBuilder:
                (context, index) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
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
                        Image.asset(introData[index]['image']!, height: 280),
                        const SizedBox(height: 32),
                        Text(
                          introData[index]['text']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: Obx(() {
              int currentPage = controller.currentPage.value;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      introData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentPage == index ? 16 : 12,
                        height: 12,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              currentPage == index
                                  ? kPrimaryColor
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  if (currentPage == introData.length - 1)
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor:
                              Colors.white, // <- Ini bikin teksnya jadi putih
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 4,
                        ),
                        onPressed: () => Get.offAllNamed('/login'),
                        child: const Text(
                          "Masuk",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
