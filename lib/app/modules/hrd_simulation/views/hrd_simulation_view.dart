import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../controllers/hrd_simulation_controller.dart';

class HrdSimulationView extends GetView<HrdSimulationController> {
  const HrdSimulationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulasi Wawancara HRD'),
        centerTitle: true,
        actions: [
          Obx(
            () =>
                controller.sessionActive.value
                    ? IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: controller.endSession,
                      tooltip: 'Akhiri Sesi',
                    )
                    : const SizedBox(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // HRD Avatar with Emotion
              AvatarGlow(
                glowColor:
                    controller.isRecording.value ? Colors.red : Colors.blue,
                endRadius: 70.0,
                duration: const Duration(milliseconds: 2000),
                repeat: true,
                child: CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  radius: 40,
                  child: Obx(
                    () => Text(
                      controller.hrdEmoji.value,
                      style: const TextStyle(fontSize: 36),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Session Status
              Obx(
                () => Text(
                  controller.sessionActive.value
                      ? 'Pertanyaan ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}'
                      : 'Tekan tombol untuk memulai',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Current Question
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    controller.currentQuestion.value,
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Timer and Feedback
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      '⏱ ${controller.timerSeconds.value}s',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Obx(
                      () =>
                          controller.feedback.value.isNotEmpty
                              ? Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  controller.feedback.value,
                                  style: TextStyle(
                                    color: Colors.amber[800],
                                    fontSize: 14,
                                  ),
                                ),
                              )
                              : const SizedBox(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Live Transcript
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Transkrip Jawaban:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Obx(
                              () => Text(
                                controller.userResponse.value.isNotEmpty
                                    ? controller.userResponse.value
                                    : 'Mulai berbicara...',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Error Message
              Obx(
                () =>
                    controller.errorMessage.value.isNotEmpty
                        ? Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Text(
                            controller.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        )
                        : const SizedBox(),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: Obx(() {
        if (!controller.sessionActive.value) {
          return FloatingActionButton.extended(
            onPressed: controller.startSession,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Mulai Sesi'),
            backgroundColor: Colors.green,
          );
        }
        return FloatingActionButton(
          onPressed:
              controller.isRecording.value
                  ? controller.stopRecording
                  : controller.startRecording,
          backgroundColor:
              controller.isRecording.value ? Colors.red : Colors.blue,
          child: Icon(
            controller.isRecording.value ? Icons.stop : Icons.mic,
            size: 30,
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
