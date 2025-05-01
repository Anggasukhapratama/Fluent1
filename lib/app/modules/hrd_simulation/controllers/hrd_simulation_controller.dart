import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:confetti/confetti.dart';
import '../../../data/services/api_service.dart';

class HrdSimulationController extends GetxController {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ConfettiController _confettiController = ConfettiController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();

  // State variables
  var isListening = false.obs;
  var userResponse = ''.obs;
  var currentQuestion = ''.obs;
  var sessionId = ''.obs;
  var questions = <String>[].obs;
  var currentQuestionIndex = 0.obs;
  var timerSeconds = 30.obs;
  var sessionActive = false.obs;
  var hrdEmotion = 'neutral'.obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var hrdEmoji = '😐'.obs;
  var feedback = ''.obs;
  var audioPath = ''.obs;
  var isRecording = false.obs;
  var allResponses = <Map<String, dynamic>>[].obs;
  var showConfetti = false.obs;
  var recordingWave = 0.0.obs;
  var transcript = ''.obs;

  Timer? _recordingTimer;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    _initRecorder();
    _confettiController.addListener(() {
      showConfetti.value =
          _confettiController.state == ConfettiControllerState.playing;
    });
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    _recorder.closeRecorder();
    _audioPlayer.dispose();
    _confettiController.dispose();
    _speech.stop();
    super.onClose();
  }

  void resetSessionState() {
    userResponse.value = '';
    transcript.value = '';
    hrdEmotion.value = 'neutral';
    hrdEmoji.value = '😐';
    feedback.value = '';
    errorMessage.value = '';
    allResponses.clear();
    audioPath.value = '';
    isRecording.value = false;
    isListening.value = false;
    recordingWave.value = 0.0;
    _recordingTimer?.cancel();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => errorMessage.value = 'Speech error: $error',
      );
      if (!available) errorMessage.value = 'Speech recognition not available';
    } catch (e) {
      errorMessage.value = 'Error initializing speech: $e';
    }
  }

  Future<void> _initRecorder() async {
    try {
      final status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw 'Microphone permission not granted';
      }
      await _recorder.openRecorder();
    } catch (e) {
      errorMessage.value = 'Error initializing recorder: $e';
    }
  }

  // 2. Then make sure you're calling it correctly in startSession():
  Future<void> startSession() async {
    try {
      isLoading(true);
      resetSessionState(); // Call it here at the start

      final response = await _apiService.startHRSimulation('medium');

      if (response['status'] == 'success') {
        sessionId.value = response['session_id'];
        questions.assignAll(List<String>.from(response['questions']));
        currentQuestionIndex.value = 0;
        currentQuestion.value = questions.first;
        sessionActive.value = true;
        timerSeconds.value = 30;

        Get.snackbar(
          'Success',
          'Session started',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        throw response['message'] ?? 'Failed to start session';
      }
    } catch (e) {
      errorMessage.value = 'Failed to start session: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  // Add this method to HrdSimulationController
  // 3. And also in resetQuestionState():
  void resetQuestionState() {
    userResponse.value = '';
    transcript.value = '';
    timerSeconds.value = 30;
    audioPath.value = '';
    hrdEmotion.value = 'neutral';
    hrdEmoji.value = '😐';
    feedback.value = '';
    isRecording.value = false;
    isListening.value = false;
    recordingWave.value = 0.0;
    _recordingTimer?.cancel();
  }

  Future<void> startRecording() async {
    try {
      final dir = await getTemporaryDirectory();
      audioPath.value =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      // Initialize speech recognition if not already initialized
      if (!_speech.isAvailable) {
        await _initSpeech();
      }

      await _recorder.startRecorder(
        toFile: audioPath.value,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );
      isRecording(true);

      // Start listening with proper configuration
      _speech.listen(
        onResult: (result) {
          userResponse.value = result.recognizedWords;
          if (result.finalResult) {
            transcript.value = result.recognizedWords;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: (level) => recordingWave.value = level ?? 0.0,
        localeId: 'id_ID', // Important for Indonesian language
        cancelOnError: true,
        partialResults: true,
      );

      _startRecordingTimer();
    } catch (e) {
      errorMessage.value = 'Error starting recording: $e';
      Get.snackbar(
        'Recording Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startRecordingTimer() {
    timerSeconds.value = 30;
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;

        // Update UI based on remaining time
        if (timerSeconds.value < 10 && userResponse.value.isEmpty) {
          hrdEmotion.value = 'confused';
          hrdEmoji.value = '🤔';
          feedback.value = 'Waktu hampir habis! Silakan jawab pertanyaan.';
        }
      } else {
        timer.cancel();
        _handleTimeout();
      }
    });
  }

  Future<void> _handleTimeout() async {
    try {
      await stopRecording();

      // If no speech was detected, use whatever was in userResponse
      if (transcript.value.isEmpty && userResponse.value.isNotEmpty) {
        transcript.value = userResponse.value;
      }

      // If we have any response (even partial), process it
      if (transcript.value.isNotEmpty) {
        await processAnswer();
      } else {
        // No response at all, move to next question
        await _moveToNextQuestionOrEnd();
      }
    } catch (e) {
      errorMessage.value = 'Error handling timeout: $e';
      debugPrint(errorMessage.value);
    }
  }

  Future<void> _moveToNextQuestionOrEnd() async {
    if (currentQuestionIndex.value < questions.length - 1) {
      currentQuestionIndex.value++;
      currentQuestion.value = questions[currentQuestionIndex.value];
      resetQuestionState();
    } else {
      await endSession();
    }
  }

  Future<void> stopRecording() async {
    try {
      await _recorder.stopRecorder();
      await _speech.stop();
      isRecording(false);
      _recordingTimer?.cancel();

      // Process answer if we have any transcript
      if (transcript.value.isNotEmpty || userResponse.value.isNotEmpty) {
        transcript.value =
            transcript.value.isNotEmpty ? transcript.value : userResponse.value;
        await processAnswer();
      } else {
        await _moveToNextQuestionOrEnd();
      }
    } catch (e) {
      errorMessage.value = 'Error stopping recording: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> processAnswer() async {
    try {
      isLoading(true);

      final audioFile = File(audioPath.value);
      if (!await audioFile.exists()) {
        throw 'Audio file not found';
      }

      final response = await _apiService.processHRResponse(
        audioPath: audioPath.value,
        sessionId: sessionId.value,
        questionIndex: currentQuestionIndex.value,
        transcript: transcript.value,
      );

      if (response['status'] == 'success') {
        hrdEmotion.value = response['emotion'] ?? 'neutral';
        hrdEmoji.value = response['emoji'] ?? '😐';
        feedback.value = response['feedback'] ?? '';

        allResponses.add({
          'question': currentQuestion.value,
          'response': transcript.value,
          'audio_path': audioPath.value,
          'feedback': feedback.value,
          'emotion': hrdEmotion.value,
          'timestamp': DateTime.now().toIso8601String(),
        });

        if (currentQuestionIndex.value < questions.length - 1) {
          await Future.delayed(const Duration(seconds: 2));
          currentQuestionIndex.value++;
          currentQuestion.value = questions[currentQuestionIndex.value];
          resetQuestionState();
        } else {
          _confettiController.play();
          await Future.delayed(const Duration(seconds: 2));
          await endSession();
        }
      } else {
        throw response['message'] ?? 'Failed to process answer';
      }
    } catch (e) {
      errorMessage.value = 'Error processing answer: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> endSession() async {
    try {
      isLoading(true);
      final response = await _apiService.endHRSimulation(sessionId.value);

      if (response['status'] == 'success') {
        Get.offNamed(
          '/home',
          arguments: {
            'show_result': true,
            'score': response['score'],
            'feedback': response['feedback'],
          },
        );
      } else {
        throw response['message'] ?? 'Failed to end session';
      }
    } catch (e) {
      errorMessage.value = 'Error ending session: $e';
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }
}
