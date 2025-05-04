import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:avatar_glow/avatar_glow.dart';
import '../controllers/hrd_simulation_controller.dart';

class HrdSimulationView extends GetView<HrdSimulationController> {
  const HrdSimulationView({super.key});

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
              // Avatar Section
              _buildAvatarSection(),
              const SizedBox(height: 20),

              // Question Section
              _buildQuestionSection(),
              const SizedBox(height: 20),

              // Timer and Feedback
              _buildTimerFeedbackSection(),
              const SizedBox(height: 20),

              // Response Section
              _buildResponseSection(),

              // Error Message
              _buildErrorMessage(),
            ],
          );
        }),
      ),
      floatingActionButton: _buildActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        _buildAvatar(),
        const SizedBox(height: 10),
        _buildSessionStatus(),
      ],
    );
  }

  Widget _buildAvatar() {
    return Obx(
      () => AvatarGlow(
        glowColor: controller.isRecording.value ? Colors.red : Colors.blue,
        endRadius: 70.0,
        duration: const Duration(milliseconds: 2000),
        repeat: true,
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          radius: 40,
          child: Text(
            controller.hrdEmoji.value,
            style: const TextStyle(fontSize: 36),
          ),
        ),
      ),
    );
  }

  Widget _buildSessionStatus() {
    return Obx(
      () => Text(
        controller.sessionActive.value
            ? 'Pertanyaan ${controller.currentQuestionIndex.value + 1}/${controller.questions.length}'
            : 'Tekan tombol untuk memulai',
        style: Get.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildQuestionSection() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Text(
            controller.currentQuestion.value,
            style: Get.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTimerFeedbackSection() {
    return Row(
      children: [
        _buildTimer(),
        const SizedBox(width: 10),
        Expanded(child: _buildFeedback()),
      ],
    );
  }

  Widget _buildTimer() {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '⏱ ${controller.timerSeconds.value}s',
          style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            controller.feedback.value.isNotEmpty
                ? Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _getFeedbackColor(controller.hrdEmotion.value),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    controller.feedback.value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
                : const SizedBox(),
      ),
    );
  }

  Widget _buildResponseSection() {
    return Expanded(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transkrip Jawaban:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              if (controller.transcript.value.isNotEmpty)
                _buildAnalysisSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          'Hasil Analisis:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 5),
        Obx(
          () => Text(
            controller.feedback.value,
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Obx(
      () => AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child:
            controller.errorMessage.value.isNotEmpty
                ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                )
                : const SizedBox(),
      ),
    );
  }

  Widget _buildActionButton() {
    return Obx(() {
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
    });
  }

  Color _getFeedbackColor(String emotion) {
    switch (emotion.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'concerned':
        return Colors.orange;
      case 'angry':
        return Colors.red;
      case 'waiting':
        return Colors.blue;
      default:
        return Colors.blue;
    }
  }
}
