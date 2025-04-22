import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../controllers/detection_controller.dart';

class ScrollingText extends StatefulWidget {
  final String text;
  final Duration scrollDuration;

  const ScrollingText({
    super.key,
    required this.text,
    this.scrollDuration = const Duration(seconds: 10),
  });

  @override
  State<ScrollingText> createState() => _ScrollingTextState();
}

class _ScrollingTextState extends State<ScrollingText> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animateText();
    });
  }

  void _animateText() {
    final textWidth = _calculateTextWidth(widget.text);
    final screenWidth = MediaQuery.of(Get.context!).size.width;
    final scrollDistance = textWidth - screenWidth + 32;

    if (scrollDistance > 0) {
      _scrollController.animateTo(
        scrollDistance,
        duration: widget.scrollDuration,
        curve: Curves.linear,
      );
    }
  }

  double _calculateTextWidth(String text) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Text(
        widget.text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

class DetectionView extends StatelessWidget {
  const DetectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DetectionController());
    final screenHeight = MediaQuery.of(context).size.height;
    final cameraHeight = screenHeight * 0.55;
    final bottomPanelHeight = screenHeight * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(
          45,
        ), // default biasanya 56, ini lebih kecil
        child: AppBar(
          title: const Text(
            'Latihan Wawancara AI',
            style: TextStyle(fontSize: 16),
          ),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
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
        if (controller.showResults.value) return _buildResultsView(controller);
        if (controller.showInstructions.value)
          return _buildInstructions(controller);
        if (controller.showScript.value)
          return _buildInterviewScript(controller);
        return _buildMainInterface(controller, cameraHeight, bottomPanelHeight);
      }),
    );
  }

  Widget _buildInstructions(DetectionController controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 20),
          const Text(
            'Petunjuk Penggunaan',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const Text(
            '1. Pilih level kesulitan wawancara\n'
            '2. Baca script perkenalan yang muncul\n'
            '3. Sistem akan menganalisis:\n'
            '   - Ekspresi wajah dan bahasa tubuh\n'
            '   - Kelancaran dan kejelasan bicara\n'
            '4. Dapatkan feedback lengkap',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 30),
          const Text(
            'Pilih Level Kesulitan:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Medium'),
                selected: controller.selectedDifficulty.value == 'medium',
                onSelected:
                    (selected) =>
                        controller.selectedDifficulty.value = 'medium',
              ),
              const SizedBox(width: 20),
              ChoiceChip(
                label: const Text('Hard'),
                selected: controller.selectedDifficulty.value == 'hard',
                onSelected:
                    (selected) => controller.selectedDifficulty.value = 'hard',
              ),
            ],
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              controller.showInstructions.value = false;
              controller.showScript.value = true;
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 30),
            ),
            child: const Text('Mulai Latihan'),
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
          const Icon(Icons.assignment, size: 60, color: Colors.blueAccent),
          const SizedBox(height: 20),
          Text(
            'Script Wawancara - ${controller.selectedDifficulty.value == 'medium' ? 'Medium' : 'Sulit'}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children:
                  controller
                      .interviewScripts[controller.selectedDifficulty.value]!
                      .asMap()
                      .entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${entry.key + 1}. '),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Setiap kalimat akan ditampilkan selama 5 detik dengan efek scroll',
            style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  controller.showScript.value = false;
                  controller.showInstructions.value = true;
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(120, 50),
                  side: const BorderSide(color: Colors.blueAccent),
                ),
                child: const Text('Kembali'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: controller.startInterviewPractice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(120, 50),
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
                padding: const EdgeInsets.all(12.0),
                child: Obx(
                  () =>
                      controller.isCameraInitialized.value
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
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
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Obx(
                    () => Text(
                      controller.selectedCameraIndex.value == 0
                          ? "Kamera Depan"
                          : "Kamera Belakang",
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                right: 20,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white.withOpacity(0.7),
                  onPressed: controller.switchCamera,
                  child: const Icon(
                    Icons.switch_camera,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
              if (controller.isListening.value)
                Positioned(
                  top: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${controller.recognizedText.value.split(' ').length} kata",
                          style: const TextStyle(color: Colors.white),
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  "Analisis Realtime",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _infoBox("Emosi", controller.emotion),
                            _infoBox("Mulut", controller.mouth),
                            _infoBox("Pose", controller.pose),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildSpeechAnalysis(controller),
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
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
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

      return Column(
        children: [
          if (controller.isListening.value ||
              controller.isAnalyzingSpeech.value)
            LinearProgressIndicator(
              value: controller.isAnalyzingSpeech.value ? null : 0,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          if (controller.isListening.value) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                "Bacalah:",
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              constraints: const BoxConstraints(maxHeight: 60),
              child: ScrollingText(
                text: currentScript,
                scrollDuration: Duration(
                  seconds: currentScript.length ~/ 15 + 3,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                "Kecepatan: ${controller.wordsPerMinute.value} WPM",
                style: TextStyle(
                  color: _getWpmColor(controller.wordsPerMinute.value),
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ],
      );
    });
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
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.summary.value,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.resetInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Mulai Latihan Baru'),
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

  Widget _infoBox(String title, RxString value) {
    return Obx(
      () => Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
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
