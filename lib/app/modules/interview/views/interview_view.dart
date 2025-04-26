import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart'; // optional icon package
import '../controllers/interview_controller.dart';

class InterviewView extends GetView<InterviewController> {
  const InterviewView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Simulasi Interview'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!controller.interviewStarted.value) {
          return _buildStartScreen();
        }

        if (controller.interviewCompleted.value) {
          return _buildResultsScreen();
        }

        return _buildInterviewScreen();
      }),
    );
  }

  Widget _buildStartScreen() {
    return Center(
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.mic, size: 60, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                'Selamat datang di simulasi interview',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: controller.startInterview,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Mulai Interview'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInterviewScreen() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              Text(
                'Pertanyaan ${controller.currentQuestionIndex.value + 1} / ${controller.totalQuestions.value}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                controller.currentQuestion.value,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Obx(
                () => Text(
                  controller.hrdEmoji.value,
                  style: const TextStyle(fontSize: 70),
                ),
              ),
            ],
          ),
          Column(
            children: [
              Obx(
                () => Text(
                  controller.transcript.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontStyle: FontStyle.italic),
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => ElevatedButton.icon(
                  onPressed:
                      controller.isRecording.value
                          ? controller.stopRecording
                          : controller.startRecording,
                  icon: Icon(
                    controller.isRecording.value
                        ? LucideIcons.stopCircle
                        : LucideIcons.mic,
                  ),
                  label: Text(
                    controller.isRecording.value ? 'Stop Jawab' : 'Mulai Jawab',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        controller.isRecording.value
                            ? Colors.red
                            : Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎉 Hasil Interview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            'Skor Keseluruhan: ${controller.overallScore.value.toStringAsFixed(1)}',
            style: const TextStyle(fontSize: 18, color: Colors.deepPurple),
          ),
          const SizedBox(height: 30),
          const Text(
            '📋 Detail Jawaban:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          ...controller.evaluationResult['questions'].map<Widget>((question) {
            return Card(
              margin: const EdgeInsets.only(bottom: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question['question_text'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Jawaban Anda: ${question['user_answer'] ?? '-'}',
                      style: const TextStyle(fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Skor: ${question['evaluation']['overall_score']?.toStringAsFixed(1) ?? '0'}',
                    ),
                    Text(
                      'Feedback: ${question['evaluation']['feedback'] ?? '-'}',
                    ),
                    const SizedBox(height: 5),
                    if (question['evaluation']['matched_keywords'] != null)
                      Text(
                        'Kata kunci: ${question['evaluation']['matched_keywords'].join(', ')}',
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton.icon(
              onPressed: () {
                controller.interviewStarted.value = false;
                controller.interviewCompleted.value = false;
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Mulai Interview Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
