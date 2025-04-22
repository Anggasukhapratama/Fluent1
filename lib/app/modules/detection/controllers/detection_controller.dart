import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;

class DetectionController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;

  // Camera & Analysis States
  RxBool isCameraInitialized = false.obs;
  RxBool isRecording = false.obs;
  RxInt selectedCameraIndex = 0.obs;

  // Detection Results
  RxString emotion = "-".obs;
  RxString mouth = "-".obs;
  RxString pose = "-".obs;
  RxString result = "Menunggu analisis...".obs;
  RxString summary = "".obs;

  // Speech Recognition
  final stt.SpeechToText speech = stt.SpeechToText();
  RxBool isListening = false.obs;
  RxString recognizedText = ''.obs;
  RxDouble confidence = 0.0.obs;
  RxList<String> speechErrors = <String>[].obs;
  RxString scriptToRead = ''.obs;

  // Interview Settings
  RxString selectedDifficulty = 'medium'.obs;
  RxBool showInstructions = true.obs;
  RxBool showScript = false.obs;
  RxBool showResults = false.obs;

  // Performance Metrics
  RxDouble speechAccuracy = 0.0.obs;
  RxDouble fluencyScore = 0.0.obs;
  RxInt pauseCount = 0.obs;
  RxBool isAnalyzingSpeech = false.obs;
  RxInt wordsPerMinute = 0.obs;

  // Script Management
  RxList<String> scriptParts = RxList<String>();
  RxInt currentScriptIndex = 0.obs;
  RxString currentScriptPart = "".obs;

  final Map<String, List<String>> interviewScripts = {
    'medium': [
      "Selamat pagi, perkenalkan nama saya [Nama Anda].",
      "Saya lulusan [Nama Universitas] dengan jurusan [Jurusan Anda].",
      "Pengalaman kerja saya selama [X tahun] di bidang [Bidang Anda].",
      "Saya menguasai keterampilan [Skill 1], [Skill 2], dan [Skill 3].",
      "Pencapaian terbesar saya adalah [Jelaskan Pencapaian].",
      "Saya tertarik dengan posisi ini karena [Alasan Anda].",
      "Kelebihan saya adalah [Sebutkan Kelebihan].",
      "Saya bisa bekerja mandiri maupun dalam tim.",
      "Saya selalu berusaha meningkatkan kemampuan diri.",
      "Terima kasih atas kesempatan wawancara ini.",
    ],
    'hard': [
      "Visi saya dalam 5 tahun ke depan adalah menjadi ahli di bidang ini.",
      "Saya memiliki pengalaman memimpin tim hingga 10 orang.",
      "Saya terbiasa bekerja di bawah tekanan dengan target ketat.",
      "Salah satu tantangan terberat saya adalah [Ceritakan Tantangan].",
      "Saya memecahkan masalah [Contoh Masalah] dengan solusi [Solusi Anda].",
      "Pendekatan saya terhadap konflik di tempat kerja adalah [Jelaskan Pendekatan].",
      "Saya percaya inovasi harus seimbang dengan eksekusi yang solid.",
      "Strategi saya untuk meningkatkan produktivitas tim adalah [Jelaskan Strategi].",
      "Saya mengikuti perkembangan industri melalui [Sebutkan Cara].",
      "Saya siap memberikan kontribusi signifikan untuk perusahaan ini.",
    ],
  };

  Timer? _timer;
  Timer? _scriptTimer;
  DateTime? _startTime;

  get stopInterviewPractice => null;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
    initSpeech();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        result.value = "Tidak ada kamera yang tersedia";
        return;
      }

      cameraController = CameraController(
        cameras[selectedCameraIndex.value],
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      result.value = "Gagal menginisialisasi kamera: $e";
    }
  }

  Future<void> initSpeech() async {
    bool available = await speech.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: $error'),
    );
    if (!available) {
      result.value = "Speech recognition not available";
    }
  }

  Future<void> switchCamera() async {
    if (cameras.length < 2) return;

    isCameraInitialized.value = false;
    await cameraController.dispose();

    selectedCameraIndex.value =
        (selectedCameraIndex.value + 1) % cameras.length;
    await initializeCamera();
  }

  void startInterviewPractice() {
    showScript.value = false;
    showResults.value = false;

    scriptParts.value = interviewScripts[selectedDifficulty.value]!;
    currentScriptIndex.value = 0;
    currentScriptPart.value = scriptParts[0];

    startListening();
    startRealtimeDetection();

    // Change to 5 seconds per sentence for faster display
    _scriptTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (currentScriptIndex.value < scriptParts.length - 1) {
        currentScriptIndex.value++;
        currentScriptPart.value = scriptParts[currentScriptIndex.value];
      } else {
        timer.cancel();
      }
    });
  }

  void startListening() {
    recognizedText.value = '';
    confidence.value = 0;
    speechErrors.value = [];
    _startTime = DateTime.now();

    speech.listen(
      onResult: (result) {
        recognizedText.value = result.recognizedWords;
        confidence.value = result.confidence;
        _analyzeSpeech(result.recognizedWords);
      },
      listenFor: Duration(seconds: 30),
      pauseFor: Duration(seconds: 3),
      partialResults: true,
    );

    isListening.value = true;
  }

  Future<void> startRealtimeDetection() async {
    if (!isCameraInitialized.value) return;

    isRecording.value = true;
    result.value = "Memulai analisis realtime...";

    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 2), (timer) async {
      await analyzeSnapshot();
    });
  }

  Future<void> stopDetection() async {
    isRecording.value = false;
    isListening.value = false;
    speech.stop();
    _timer?.cancel();
    _scriptTimer?.cancel();

    final duration = DateTime.now().difference(_startTime!).inSeconds;
    wordsPerMinute.value =
        (recognizedText.value.split(' ').length / duration * 60).round();

    summary.value = _generateEnhancedSummary();
    showResults.value = true;
  }

  void _analyzeSpeech(String spokenText) {
    isAnalyzingSpeech.value = true;

    final currentScript = scriptParts[currentScriptIndex.value];

    double similarity = _calculateSimilarity(
      spokenText.toLowerCase(),
      currentScript.toLowerCase(),
    );

    speechAccuracy.value = similarity * 100;

    final wordCount = spokenText.split(' ').length;
    final timeElapsed = DateTime.now().difference(_startTime!).inSeconds;
    wordsPerMinute.value = (wordCount / timeElapsed * 60).round();

    // Ideal WPM for speech: 120-150
    if (wordsPerMinute.value < 100) {
      if (!speechErrors.contains('Berbicara terlalu lambat')) {
        speechErrors.add(
          'Berbicara terlalu lambat (${wordsPerMinute.value} WPM)',
        );
      }
    } else if (wordsPerMinute.value > 180) {
      if (!speechErrors.contains('Berbicara terlalu cepat')) {
        speechErrors.add(
          'Berbicara terlalu cepat (${wordsPerMinute.value} WPM)',
        );
      }
    }

    // Detect filler words
    final fillerWords = ['umm', 'ahh', 'ehh', 'mmm', 'hmm'];
    int fillerCount =
        spokenText
            .toLowerCase()
            .split(' ')
            .where((word) => fillerWords.contains(word))
            .length;
    pauseCount.value = fillerCount;

    if (fillerCount > 5 &&
        !speechErrors.contains('Terlalu banyak kata pengisi')) {
      speechErrors.add('Terlalu banyak kata pengisi (umm, ahh)');
    }

    fluencyScore.value =
        100 -
        (fillerCount * 2 +
            (wordsPerMinute.value < 100 || wordsPerMinute.value > 180
                ? 20
                : 0));

    isAnalyzingSpeech.value = false;
  }

  double _calculateSimilarity(String a, String b) {
    // Remove punctuation for better comparison
    String cleanA = a.replaceAll(RegExp(r'[^\w\s]'), '');
    String cleanB = b.replaceAll(RegExp(r'[^\w\s]'), '');

    Set<String> setA = cleanA.split(' ').toSet();
    Set<String> setB = cleanB.split(' ').toSet();

    int intersection = setA.intersection(setB).length;
    int union = setA.union(setB).length;

    return union == 0 ? 0 : intersection / union;
  }

  Future<void> analyzeSnapshot() async {
    if (!cameraController.value.isInitialized || !isRecording.value) return;

    try {
      final XFile file = await cameraController.takePicture();
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await http
          .post(
            Uri.parse("http://192.168.167.186:5000/analyze_realtime"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"frame": base64Image}),
          )
          .timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          emotion.value = data['results']['emotion'] ?? "-";
          mouth.value = data['results']['mouth'] ?? "-";
          pose.value = data['results']['pose'] ?? "-";
        }
      }
    } catch (e) {
      print("Error analyzing frame: $e");
    }
  }

  String _generateEnhancedSummary() {
    final buffer = StringBuffer();

    buffer.writeln("=== HASIL ANALISIS WAWANCARA ===");
    buffer.writeln("Skor Akurasi: ${speechAccuracy.value.toStringAsFixed(1)}%");
    buffer.writeln("Kecepatan Bicara: ${wordsPerMinute.value} kata per menit");
    buffer.writeln("Jumlah Kata Pengisi: ${pauseCount.value}");

    if (speechAccuracy.value >= 80) {
      buffer.writeln("\n✅ Pembacaan Anda sangat akurat!");
    } else if (speechAccuracy.value >= 60) {
      buffer.writeln(
        "\n⚠️ Pembacaan Anda cukup baik, tetapi masih ada beberapa kesalahan",
      );
    } else {
      buffer.writeln(
        "\n❌ Pembacaan Anda masih banyak kesalahan, perlu lebih banyak latihan",
      );
    }

    buffer.writeln("\n=== ANALISIS BAHASA TUBUH ===");
    buffer.writeln("Ekspresi: ${emotion.value}");
    buffer.writeln("Gerakan Mulut: ${mouth.value}");
    buffer.writeln("Postur: ${pose.value}");

    buffer.writeln("\n=== SARAN PERBAIKAN ===");
    if (wordsPerMinute.value < 100) {
      buffer.writeln("- Cobalah berbicara lebih cepat");
    } else if (wordsPerMinute.value > 180) {
      buffer.writeln("- Cobalah berbicara lebih lambat dan jelas");
    }

    if (pauseCount.value > 5) {
      buffer.writeln("- Kurangi penggunaan kata pengisi seperti 'umm', 'ahh'");
    }

    if (speechAccuracy.value < 80) {
      buffer.writeln("- Latih pengucapan kalimat dengan lebih baik");
      buffer.writeln("- Perhatikan intonasi dan penekanan kata");
    }

    return buffer.toString();
  }

  void resetInterview() {
    showInstructions.value = true;
    showScript.value = false;
    showResults.value = false;
    isRecording.value = false;
    isListening.value = false;
    speech.stop();
    _timer?.cancel();
    _scriptTimer?.cancel();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _scriptTimer?.cancel();
    speech.stop();
    cameraController.dispose();
    super.onClose();
  }
}
