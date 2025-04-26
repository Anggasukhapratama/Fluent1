import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:fluent/app/data/services/api_service.dart';

class DetectionController extends GetxController {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  final ApiService apiService = ApiService();
  final stt.SpeechToText speech = stt.SpeechToText();

  // Camera & Analysis States
  RxBool isCameraInitialized = false.obs;
  RxBool isRecording = false.obs;
  RxInt selectedCameraIndex = 0.obs;

  // Detection Results
  RxString emotion = "-".obs;
  RxString mouth = "-".obs;
  RxString pose = "-".obs;
  RxString result = "Waiting for analysis...".obs;
  RxString summary = "".obs;

  // Speech Recognition
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
  RxBool showCustomScriptInput = false.obs;
  TextEditingController customScriptController = TextEditingController();

  // Performance Metrics
  RxDouble speechAccuracy = 0.0.obs;
  RxDouble fluencyScore = 0.0.obs;
  RxInt pauseCount = 0.obs;
  RxBool isAnalyzingSpeech = false.obs;
  RxInt wordsPerMinute = 0.obs;

  // Script Management
  RxList<String> scriptParts = <String>[].obs;
  RxInt currentScriptIndex = 0.obs;
  RxString currentScriptPart = "".obs;

  // Timer and Countdown
  RxInt countdown = 0.obs;
  RxString elapsedTime = "00:00".obs;
  DateTime? recordingStartTime;
  Timer? elapsedTimer;

  final Map<String, List<String>> interviewScripts = {
    'medium': [
      "Selamat pagi, perkenalkan nama saya [Nama Anda].",
      "Saya lulusan [Nama Universitas] dengan jurusan [Jurusan Anda].",
      "Pengalaman kerja saya selama [X tahun] di bidang [Bidang Anda].",
      "Saya menguasai keterampilan [Skill 1], [Skill 2], dan [Skill 3].",
      "Pencapaian terbesar saya adalah [Jelaskan Pencapaian].",
    ],
    'hard': [
      "Visi saya dalam 5 tahun ke depan adalah menjadi ahli di bidang ini.",
      "Saya memiliki pengalaman memimpin tim hingga 10 orang.",
      "Saya terbiasa bekerja di bawah tekanan dengan target ketat.",
      "Salah satu tantangan terberat saya adalah [Ceritakan Tantangan].",
      "Saya memecahkan masalah [Contoh Masalah] dengan solusi [Solusi Anda].",
    ],
    'custom': ["Custom script will appear here"],
  };

  Timer? _timer;
  Timer? _scriptTimer;
  DateTime? _startTime;

  @override
  void onInit() async {
    super.onInit();
    await ApiService.init();
    await initializeCamera();
    await initSpeech();
  }

  Future<void> initializeCamera() async {
    try {
      cameras = await availableCameras();
      if (cameras.isEmpty) {
        result.value = "No cameras available";
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
      result.value = "Failed to initialize camera: $e";
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

  void startCountdown() async {
    countdown.value = 3;
    showScript.value = false;

    // Countdown from 3 to 1
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (countdown.value > 1) {
        countdown.value--;
      } else {
        timer.cancel();
        countdown.value = 0;
        startInterviewPractice();
      }
    });
  }

  void startInterviewPractice() {
    showScript.value = false;
    showResults.value = false;

    if (selectedDifficulty.value == 'custom') {
      scriptParts.value =
          customScriptController.text
              .split('\n')
              .where((line) => line.trim().isNotEmpty)
              .toList();
    } else {
      scriptParts.value = interviewScripts[selectedDifficulty.value]!;
    }

    currentScriptIndex.value = 0;
    currentScriptPart.value = scriptParts[0];

    // Start elapsed time timer
    recordingStartTime = DateTime.now();
    elapsedTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final duration = DateTime.now().difference(recordingStartTime!);
      final minutes = duration.inMinutes
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      final seconds = duration.inSeconds
          .remainder(60)
          .toString()
          .padLeft(2, '0');
      elapsedTime.value = '$minutes:$seconds';
    });

    // Start listening after a small delay
    Future.delayed(Duration(milliseconds: 500), () {
      startListening();
      startRealtimeDetection();
    });

    _scriptTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (currentScriptIndex.value < scriptParts.length - 1) {
        currentScriptIndex.value++;
        currentScriptPart.value = scriptParts[currentScriptIndex.value];
      } else {
        timer.cancel();
      }
    });
  }

  void resetInterview() {
    showInstructions.value = true;
    showScript.value = false;
    showResults.value = false;
    showCustomScriptInput.value = false;
    isRecording.value = false;
    isListening.value = false;
    speech.stop();
    _timer?.cancel();
    _scriptTimer?.cancel();
    elapsedTimer?.cancel();
    elapsedTime.value = "00:00";
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

  void _analyzeSpeech(String spokenText) {
    isAnalyzingSpeech.value = true;

    final currentScript = scriptParts[currentScriptIndex.value];
    final similarity = _calculateSimilarity(spokenText, currentScript);
    speechAccuracy.value = similarity * 100;

    final wordCount = spokenText.split(' ').length;
    final timeElapsed = DateTime.now().difference(_startTime!).inSeconds;
    wordsPerMinute.value = (wordCount / timeElapsed * 60).round();

    // Detect filler words
    final fillerWords = ['umm', 'ahh', 'ehh', 'mmm', 'hmm'];
    pauseCount.value =
        spokenText
            .toLowerCase()
            .split(' ')
            .where((word) => fillerWords.contains(word))
            .length;

    fluencyScore.value = 100 - (pauseCount.value * 2);
    isAnalyzingSpeech.value = false;
  }

  double _calculateSimilarity(String a, String b) {
    final cleanA = a.replaceAll(RegExp(r'[^\w\s]'), '');
    final cleanB = b.replaceAll(RegExp(r'[^\w\s]'), '');
    final setA = cleanA.split(' ').toSet();
    final setB = cleanB.split(' ').toSet();
    final intersection = setA.intersection(setB).length;
    final union = setA.union(setB).length;
    return union == 0 ? 0 : intersection / union;
  }

  Future<void> analyzeSnapshot() async {
    if (!cameraController.value.isInitialized || !isRecording.value) return;

    try {
      final XFile file = await cameraController.takePicture();
      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);

      final response = await apiService.analyzeRealtime(base64Image);

      if (response['status'] == 'success') {
        emotion.value = response['results']['emotion'] ?? "-";
        mouth.value = response['results']['mouth'] ?? "-";
        pose.value = response['results']['pose'] ?? "-";
      } else {
        print("Analysis error: ${response['message']}");
      }
    } catch (e) {
      print("Error analyzing frame: $e");
    }
  }

  void startRealtimeDetection() {
    isRecording.value = true;
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
    elapsedTimer?.cancel();

    final duration = DateTime.now().difference(_startTime!).inSeconds;
    wordsPerMinute.value =
        (recognizedText.value.split(' ').length / duration * 60).round();

    summary.value = _generateEnhancedSummary();
    showResults.value = true;
  }

  String _generateEnhancedSummary() {
    final buffer = StringBuffer();
    buffer.writeln("=== INTERVIEW ANALYSIS RESULTS ===");
    buffer.writeln("Accuracy: ${speechAccuracy.value.toStringAsFixed(1)}%");
    buffer.writeln("Speaking Rate: ${wordsPerMinute.value} WPM");
    buffer.writeln("Filler Words: ${pauseCount.value}");
    buffer.writeln("\nEmotion: ${emotion.value}");
    buffer.writeln("Mouth Movement: ${mouth.value}");
    buffer.writeln("Posture: ${pose.value}");
    return buffer.toString();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _scriptTimer?.cancel();
    elapsedTimer?.cancel();
    speech.stop();
    cameraController.dispose();
    customScriptController.dispose();
    super.onClose();
  }
}
