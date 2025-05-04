import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:confetti/confetti.dart';
import '../../../data/services/api_service.dart';

class HrdSimulationController extends GetxController {
  final ApiService _apiService = ApiService();
  final stt.SpeechToText speech = stt.SpeechToText();
  final AudioPlayer audioPlayer = AudioPlayer();
  final ConfettiController confettiController = ConfettiController();
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();

  // State variables
  final RxBool isListening = false.obs;
  final RxString userResponse = ''.obs;
  final RxString currentQuestion = ''.obs;
  final RxString sessionId = ''.obs;
  final RxList<String> questions = <String>[].obs;
  final RxInt currentQuestionIndex = 0.obs;
  final RxInt timerSeconds = 30.obs;
  final RxBool sessionActive = false.obs;
  final RxString hrdEmotion = 'neutral'.obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString hrdEmoji = '😐'.obs;
  final RxString feedback = ''.obs;
  final RxString audioPath = ''.obs;
  final RxBool isRecording = false.obs;
  final RxList<Map<String, dynamic>> allResponses =
      <Map<String, dynamic>>[].obs;
  final RxBool showConfetti = false.obs;
  final RxDouble recordingWave = 0.0.obs;
  final RxString transcript = ''.obs;

  Timer? recordingTimer;
  Timer? speechLevelTimer;
  bool isRecorderInitialized = false;
  bool isSpeechInitialized = false;

  @override
  void onInit() {
    super.onInit();
    initializeAll();
    confettiController.addListener(() {
      showConfetti.value =
          confettiController.state == ConfettiControllerState.playing;
    });
  }

  @override
  void onClose() {
    recordingTimer?.cancel();
    speechLevelTimer?.cancel();
    recorder.closeRecorder();
    audioPlayer.dispose();
    confettiController.dispose();
    speech.stop();
    super.onClose();
  }

  Future<void> initializeAll() async {
    try {
      await initRecorder();
      await initSpeech();
    } catch (e) {
      errorMessage.value = 'Initialization error: ${e.toString()}';
      debugPrint(errorMessage.value);
    }
  }

  Future<void> initRecorder() async {
    try {
      final status = await Permission.microphone.status;
      if (!status.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          throw 'Microphone permission denied';
        }
      }

      await recorder.openRecorder();
      await recorder.setSubscriptionDuration(const Duration(milliseconds: 50));
      isRecorderInitialized = true;
    } catch (e) {
      isRecorderInitialized = false;
      errorMessage.value = 'Recorder init error: ${e.toString()}';
      debugPrint(errorMessage.value);
    }
  }

  Future<void> initSpeech() async {
    try {
      isSpeechInitialized = await speech.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) {
          errorMessage.value = 'Speech error: $error';
          debugPrint('Speech error: $error');
        },
      );
    } catch (e) {
      isSpeechInitialized = false;
      errorMessage.value = 'Speech init error: ${e.toString()}';
      debugPrint(errorMessage.value);
    }
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
    recordingTimer?.cancel();
    speechLevelTimer?.cancel();
  }

  Future<void> startSession() async {
    try {
      isLoading(true);
      resetSessionState();

      final response = await _apiService.startHRSimulation('medium');

      if (response['status'] == 'success') {
        sessionId.value = response['session_id'];
        questions.assignAll(List<String>.from(response['questions']));
        currentQuestionIndex.value = 0;
        currentQuestion.value = questions.first;
        sessionActive.value = true;
        timerSeconds.value = 30;
      } else {
        throw response['message'] ?? 'Failed to start session';
      }
    } catch (e) {
      errorMessage.value = 'Failed to start session: $e';
    } finally {
      isLoading(false);
    }
  }

  Future<void> startRecording() async {
    try {
      if (!isRecorderInitialized) await initRecorder();
      if (!isSpeechInitialized) await initSpeech();

      final dir = await getTemporaryDirectory();
      audioPath.value =
          '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.wav';

      await recorder.startRecorder(
        toFile: audioPath.value,
        codec: Codec.pcm16WAV,
        sampleRate: 16000,
      );
      isRecording(true);

      final success = await speech.listen(
        onResult: (result) {
          userResponse.value = result.recognizedWords;
          if (result.finalResult) {
            transcript.value = result.recognizedWords;
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange:
            (level) => recordingWave.value = (level ?? 0.0) / 100,
        localeId: 'id-ID',
        cancelOnError: true,
        partialResults: true,
      );

      if (!success) throw 'Failed to start speech recognition';

      startRecordingTimer();
    } catch (e) {
      errorMessage.value = 'Error starting recording: ${e.toString()}';
      await stopRecording();
    }
  }

  void startRecordingTimer() {
    timerSeconds.value = 30;
    recordingTimer?.cancel();
    recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timerSeconds.value > 0) {
        timerSeconds.value--;
        updateFeedback();
      } else {
        timer.cancel();
        handleTimeout();
      }
    });
  }

  void updateFeedback() {
    final wordCount = userResponse.value.split(' ').length;
    if (timerSeconds.value < 10 && wordCount < 3) {
      hrdEmotion.value = 'concerned';
      hrdEmoji.value = '😟';
      feedback.value = 'Waktu hampir habis! Silakan jelaskan jawaban Anda.';
    } else if (wordCount < 5) {
      hrdEmotion.value = 'waiting';
      hrdEmoji.value = '🧐';
      feedback.value = 'Jawaban masih terlalu pendek...';
    }
  }

  Future<void> handleTimeout() async {
    try {
      await stopRecording();
      if (transcript.value.isEmpty && userResponse.value.isNotEmpty) {
        transcript.value = userResponse.value;
      }
      await processResponse();
    } catch (e) {
      errorMessage.value = 'Error handling timeout: $e';
      await moveToNextQuestionOrEnd();
    }
  }

  Future<void> stopRecording() async {
    try {
      await recorder.stopRecorder();
      await speech.stop();
      isRecording(false);
      recordingTimer?.cancel();
      speechLevelTimer?.cancel();

      if (transcript.value.isEmpty && userResponse.value.isNotEmpty) {
        transcript.value = userResponse.value;
      }
    } catch (e) {
      errorMessage.value = 'Error stopping recording: $e';
    }
  }

  Future<void> processResponse() async {
    if (transcript.value.isNotEmpty) {
      await processAnswer();
    } else {
      feedback.value = 'Tidak ada jawaban terdeteksi. Pertanyaan dilewati.';
      await moveToNextQuestionOrEnd();
    }
  }

  Future<void> processAnswer() async {
    try {
      isLoading(true);
      final audioFile = File(audioPath.value);
      if (!await audioFile.exists()) throw 'Audio file not found';

      final response = await _apiService.processHRResponse(
        audioPath: audioPath.value,
        sessionId: sessionId.value,
        questionIndex: currentQuestionIndex.value,
        transcript: transcript.value,
      );

      if (response['status'] != 'success') {
        throw response['message'] ?? 'Failed to process answer';
      }

      saveResponse(response);
      updateFeedbackFromResponse(response);

      if (currentQuestionIndex.value < questions.length - 1) {
        await moveToNextQuestion();
      } else {
        await completeSession();
      }
    } catch (e) {
      errorMessage.value = 'Error processing answer: $e';
      await moveToNextQuestionOrEnd();
    } finally {
      isLoading(false);
    }
  }

  void saveResponse(Map<String, dynamic> response) {
    allResponses.add({
      'question': currentQuestion.value,
      'response': transcript.value,
      'audio_path': audioPath.value,
      'feedback': response['feedback'] ?? '',
      'analysis': response['analysis'] ?? {},
      'emotion': response['emotion'] ?? 'neutral',
      'emoji': response['emoji'] ?? '😐',
      'timestamp': DateTime.now(),
    });
  }

  void updateFeedbackFromResponse(Map<String, dynamic> response) {
    feedback.value = response['feedback'] ?? '';
    hrdEmotion.value = response['emotion'] ?? 'neutral';
    hrdEmoji.value = response['emoji'] ?? '😐';
  }

  Future<void> moveToNextQuestion() async {
    await Future.delayed(const Duration(seconds: 2));
    currentQuestionIndex.value++;
    currentQuestion.value = questions[currentQuestionIndex.value];
    resetQuestionState();
  }

  Future<void> completeSession() async {
    confettiController.play();
    await Future.delayed(const Duration(seconds: 2));
    await endSession();
  }

  Future<void> moveToNextQuestionOrEnd() async {
    if (currentQuestionIndex.value < questions.length - 1) {
      await moveToNextQuestion();
    } else {
      await endSession();
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
            'responses': allResponses,
          },
        );
      } else {
        throw response['message'] ?? 'Failed to end session';
      }
    } catch (e) {
      errorMessage.value = 'Error ending session: $e';
    } finally {
      isLoading(false);
    }
  }

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
    recordingTimer?.cancel();
    speechLevelTimer?.cancel();
  }
}
