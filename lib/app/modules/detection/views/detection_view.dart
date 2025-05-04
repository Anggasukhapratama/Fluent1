import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import '../controllers/detection_controller.dart';

class DetectionView extends StatelessWidget {
  const DetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetectionController());
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.45;
    final bottomPanelHeight = screenHeight * 0.45;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF5E6), // Warm orange background
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(50),
        child: AppBar(
          title: const Text(
            'Deteksi Narasi Wawancara',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFE67E22), // Orange-red theme
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 5,
          actions: [
            if (controller.showResults.value)
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: controller.resetInterview,
                tooltip: 'Mulai Baru',
              ),
          ],
        ),
      ),
      body: Obx(() {
        if (controller.countdown.value > 0) return _buildCountdown(controller);
        if (controller.showResults.value) return _buildResultsView(controller);
        if (controller.showInstructions.value)
          return _buildInstructions(controller);
        if (controller.showCustomScriptInput.value)
          return _buildCustomScriptInput(controller);
        if (controller.showScript.value)
          return _buildInterviewScript(controller);
        return _buildMainInterface(controller, cameraHeight, bottomPanelHeight);
      }),
    );
  }

  Widget _buildCountdown(DetectionController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Mulai dalam",
            style: TextStyle(fontSize: 24, color: Colors.black87),
          ),
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE67E22),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                controller.countdown.value.toString(),
                style: const TextStyle(
                  fontSize: 60,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(DetectionController controller) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, size: 70, color: Color(0xFFE67E22)),
            const SizedBox(height: 20),
            const Text(
              'Petunjuk Penggunaan',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE67E22),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '1. Pilih level kesulitan wawancara\n'
                    '2. Baca script perkenalan yang muncul\n'
                    '3. Sistem akan menganalisis:\n'
                    '   - Ekspresi wajah dan bahasa tubuh\n'
                    '   - Kelancaran dan kejelasan bicara\n'
                    '4. Dapatkan feedback lengkap',
                    style: TextStyle(fontSize: 16, height: 1.5),
                    textAlign: TextAlign.start,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Pilih Level Kesulitan:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Medium'),
                  selected: controller.selectedDifficulty.value == 'medium',
                  selectedColor: const Color(0xFFE67E22),
                  onSelected:
                      (selected) =>
                          controller.selectedDifficulty.value = 'medium',
                ),
                ChoiceChip(
                  label: const Text('Hard'),
                  selected: controller.selectedDifficulty.value == 'hard',
                  selectedColor: const Color(0xFFE67E22),
                  onSelected:
                      (selected) =>
                          controller.selectedDifficulty.value = 'hard',
                ),
                ChoiceChip(
                  label: const Text('Custom'),
                  selected: controller.selectedDifficulty.value == 'custom',
                  selectedColor: const Color(0xFFE67E22),
                  onSelected: (selected) {
                    controller.selectedDifficulty.value = 'custom';
                    controller.showCustomScriptInput.value = true;
                    controller.showInstructions.value = false;
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                controller.showInstructions.value = false;
                controller.showScript.value = true;
                controller.scriptParts.value =
                    controller.interviewScripts[controller
                        .selectedDifficulty
                        .value] ??
                    [];
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 40,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Mulai Latihan',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomScriptInput(DetectionController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Icon(Icons.edit, size: 70, color: Color(0xFFE67E22)),
          const SizedBox(height: 20),
          const Text(
            'Masukkan Script Custom',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE67E22),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            'Masukkan teks wawancara Anda (pisahkan dengan enter untuk setiap kalimat)',
            style: TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            height: 200,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 5,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: TextField(
              controller: controller.customScriptController,
              maxLines: null,
              expands: true,
              decoration: const InputDecoration(
                hintText:
                    'Contoh:\nPerkenalkan nama saya...\nSaya lulusan...\nPengalaman kerja saya...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(8),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.showCustomScriptInput.value = false;
                  controller.showInstructions.value = true;
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  side: const BorderSide(color: Color(0xFFE67E22)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: Color(0xFFE67E22)),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  if (controller.customScriptController.text
                      .trim()
                      .isNotEmpty) {
                    controller.scriptParts.value = controller
                        .customScriptController
                        .text
                        .split('\n');
                    controller.showCustomScriptInput.value = false;
                    controller.showScript.value = true;
                  } else {
                    Get.snackbar(
                      'Error',
                      'Silakan masukkan script terlebih dahulu',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Lanjutkan'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewScript(DetectionController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 70, color: Color(0xFFE67E22)),
          const SizedBox(height: 20),
          Text(
            'Script Wawancara - ${controller.selectedDifficulty.value == 'medium'
                ? 'Medium'
                : controller.selectedDifficulty.value == 'hard'
                ? 'Sulit'
                : 'Custom'}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE67E22),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children:
                  controller.scriptParts.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${entry.key + 1}. ',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Setiap kalimat akan ditampilkan selama 5 detik',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.showScript.value = false;
                  if (controller.selectedDifficulty.value == 'custom') {
                    controller.showCustomScriptInput.value = true;
                  } else {
                    controller.showInstructions.value = true;
                  }
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  side: const BorderSide(color: Color(0xFFE67E22)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Kembali',
                  style: TextStyle(color: Color(0xFFE67E22)),
                ),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: controller.startCountdown,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE67E22),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Mulai Rekam'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainInterface(
    DetectionController controller,
    double cameraHeight,
    double bottomPanelHeight,
  ) {
    return Column(
      children: [
        SizedBox(
          height: cameraHeight,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () =>
                      controller.isCameraInitialized.value
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CameraPreview(controller.cameraController),
                          )
                          : const Center(child: CircularProgressIndicator()),
                ),
              ),
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(
                    () => Text(
                      controller.elapsedTime.value,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  onPressed: controller.switchCamera,
                  child: const Icon(
                    Icons.switch_camera,
                    color: Color(0xFFE67E22),
                    size: 28,
                  ),
                ),
              ),
              if (controller.isListening.value)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.mic, color: Colors.white, size: 18),
                        const SizedBox(width: 6),
                        Obx(
                          () => Text(
                            "${controller.recognizedText.value.split(' ').length} kata",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: bottomPanelHeight,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Analisis Realtime",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE67E22),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildInfoBox("Emosi", controller.emotion),
                            _buildInfoBox("Mulut", controller.mouth),
                            _buildInfoBox("Pose", controller.pose),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSpeechAnalysis(controller),
                        const SizedBox(height: 10),
                        if (controller.isListening.value)
                          _buildSpeechFeedback(controller),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed:
                          controller.isRecording.value
                              ? controller.stopDetection
                              : null,
                      icon: const Icon(Icons.stop),
                      label: const Text("Selesaikan Analisis"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE67E22),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeechAnalysis(DetectionController controller) {
    return Obx(() {
      final currentScript = controller.currentScriptPart.value;
      final maxCharsPerLine = 50;
      String firstLine = currentScript;
      String secondLine = "";
      if (currentScript.length > maxCharsPerLine) {
        int splitIndex = currentScript
            .substring(0, maxCharsPerLine)
            .lastIndexOf(' ');
        if (splitIndex == -1) splitIndex = maxCharsPerLine;
        firstLine = currentScript.substring(0, splitIndex).trim();
        secondLine = currentScript.substring(splitIndex).trim();
      }
      return Column(
        children: [
          if (controller.isListening.value ||
              controller.isAnalyzingSpeech.value)
            LinearProgressIndicator(
              value: controller.isAnalyzingSpeech.value ? null : 0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFFE67E22),
              ),
            ),
          if (controller.isListening.value) ...[
            const SizedBox(height: 10),
            const Text(
              "Bacalah",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE67E22),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8F0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE67E22).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    firstLine,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (secondLine.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      secondLine,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.speed, size: 18, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  "Kecepatan: ${controller.wordsPerMinute.value} WPM",
                  style: TextStyle(
                    color: _getWpmColor(controller.wordsPerMinute.value),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }

  Widget _buildSpeechFeedback(DetectionController controller) {
    return Obx(() {
      if (!controller.isListening.value) return const SizedBox();
      final feedbacks = <Widget>[];
      // Feedback kecepatan bicara
      if (controller.wordsPerMinute.value > 180) {
        feedbacks.add(
          _buildFeedbackItem(
            "Terlalu cepat! Coba lebih santai",
            Icons.speed,
            Colors.orange,
          ),
        );
      } else if (controller.wordsPerMinute.value < 100) {
        feedbacks.add(
          _buildFeedbackItem(
            "Terlalu lambat! Tingkatkan kecepatan",
            Icons.speed,
            Colors.orange,
          ),
        );
      }
      // Feedback filler words
      if (controller.pauseCount.value > 3) {
        feedbacks.add(
          _buildFeedbackItem(
            "Terlalu banyak jeda (${controller.pauseCount.value}x)",
            Icons.pause,
            Colors.red,
          ),
        );
      }
      // Feedback posture
      if (controller.pose.value.toLowerCase().contains("miring")) {
        feedbacks.add(
          _buildFeedbackItem(
            "Postur tubuh terlalu miring",
            Icons.airline_seat_recline_normal,
            Colors.orange,
          ),
        );
      }
      if (feedbacks.isEmpty) {
        feedbacks.add(
          _buildFeedbackItem(
            "Bagus! Pertahankan",
            Icons.thumb_up,
            Colors.green,
          ),
        );
      }
      return Column(
        children: [
          const SizedBox(height: 15),
          const Text(
            "Koreksi Realtime:",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE67E22),
            ),
          ),
          const SizedBox(height: 8),
          ...feedbacks,
        ],
      );
    });
  }

  Widget _buildFeedbackItem(String text, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsView(DetectionController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Hasil Analisis Wawancara",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFE67E22),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildResultItem(
                  "Keakuratan",
                  "${controller.speechAccuracy.value.toStringAsFixed(1)}%",
                  Icons.check_circle, // Ganti dengan ikon yang valid
                  _getAccuracyColor(controller.speechAccuracy.value),
                ),
                _buildResultItem(
                  "Kecepatan",
                  "${controller.wordsPerMinute.value} WPM",
                  Icons.speed,
                  _getWpmColor(controller.wordsPerMinute.value),
                ),
                _buildResultItem(
                  "Kelancaran",
                  "${controller.fluencyScore.value.toStringAsFixed(1)}/100",
                  Icons.bar_chart, // Ganti dengan ikon yang valid
                  _getFluencyColor(controller.fluencyScore.value),
                ),
                _buildResultItem(
                  "Ekspresi",
                  controller.emotion.value,
                  Icons.emoji_emotions,
                  Colors.blue,
                ),
                _buildResultItem(
                  "Postur",
                  controller.pose.value,
                  Icons.airline_seat_recline_normal,
                  controller.pose.value.toLowerCase().contains("baik")
                      ? Colors.green
                      : Colors.orange,
                ),
                const SizedBox(height: 15),
                const Text(
                  "Saran Perbaikan:",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE67E22),
                  ),
                ),
                const SizedBox(height: 10),
                ..._buildImprovementSuggestions(controller),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.resetInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE67E22),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Mulai Latihan Baru',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Text(
            "$title: ",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildImprovementSuggestions(DetectionController controller) {
    final suggestions = <Widget>[];
    if (controller.wordsPerMinute.value > 180) {
      suggestions.add(
        _buildSuggestionItem(
          "• Kurangi kecepatan bicara, idealnya 120-160 WPM",
        ),
      );
    } else if (controller.wordsPerMinute.value < 100) {
      suggestions.add(
        _buildSuggestionItem("• Tingkatkan kecepatan bicara sedikit"),
      );
    }
    if (controller.pauseCount.value > 3) {
      suggestions.add(
        _buildSuggestionItem("• Kurangi penggunaan filler words (umm, ahh)"),
      );
    }
    if (controller.pose.value.toLowerCase().contains("miring")) {
      suggestions.add(
        _buildSuggestionItem("• Pertahankan postur tubuh yang tegak"),
      );
    }
    if (controller.emotion.value.toLowerCase().contains("netral")) {
      suggestions.add(
        _buildSuggestionItem("• Tambahkan ekspresi wajah yang lebih hidup"),
      );
    }
    if (suggestions.isEmpty) {
      suggestions.add(
        _buildSuggestionItem("• Pertahankan performa yang sudah baik ini!"),
      );
    }
    return suggestions;
  }

  Widget _buildSuggestionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• "),
          Expanded(
            child: Text(
              text.substring(2),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Color _getWpmColor(int wpm) {
    if (wpm < 100) return Colors.orange;
    if (wpm > 180) return Colors.red;
    return Colors.green;
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy < 70) return Colors.red;
    if (accuracy < 85) return Colors.orange;
    return Colors.green;
  }

  Color _getFluencyColor(double fluency) {
    if (fluency < 70) return Colors.red;
    if (fluency < 85) return Colors.orange;
    return Colors.green;
  }

  Widget _buildInfoBox(String title, RxString value) {
    return Obx(
      () => Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8F0),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE67E22).withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFFE67E22),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value.value,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
