import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../data/services/api_service.dart';

class InterviewController extends GetxController {
  final ApiService apiService = ApiService();
  final stt.SpeechToText speech = stt.SpeechToText();
  final AudioPlayer audioPlayer = AudioPlayer();
  final FlutterSoundRecorder recorder = FlutterSoundRecorder();

  var isLoading = false.obs;
  var isRecording = false.obs;
  var isPlaying = false.obs;
  var interviewStarted = false.obs;
  var interviewCompleted = false.obs;
  var currentQuestion = ''.obs;
  var currentQuestionId = ''.obs;
  var sessionId = ''.obs;
  var totalQuestions = 0.obs;
  var currentQuestionIndex = 0.obs;
  var hrdEmoji = '😊'.obs;
  var evaluationResult = <String, dynamic>{}.obs;
  var overallScore = 0.0.obs;
  var transcript = ''.obs;

  @override
  void onInit() {
    super.onInit();
    initializeRecorder();
  }

  Future<void> initializeRecorder() async {
    await recorder.openRecorder();
  }

  Future<void> startInterview() async {
    try {
      isLoading(true);
      print('Attempting to start interview...'); // Debug log

      final response = await http.post(
        Uri.parse('${apiService.baseUrl}/api/interview/start'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_id': 'current_user_id', 'category': 'general'}),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          sessionId.value = data['session_id'];
          currentQuestion.value = data['current_question'];
          currentQuestionId.value = data['current_question_id'];
          totalQuestions.value = data['total_questions'];
          interviewStarted.value = true;

          // Debug prints
          print('Session started: ${sessionId.value}');
          print('First question: ${currentQuestion.value}');

          await playQuestionAudio(currentQuestionId.value);
        } else {
          Get.snackbar('Error', data['message'] ?? 'Failed to start interview');
        }
      } else {
        Get.snackbar('Error', 'HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Exception: $e');
      print('Exception details: $e'); // Debug log
    } finally {
      isLoading(false);
    }
  }

  Future<void> playQuestionAudio(String questionId) async {
    try {
      isPlaying(true);
      final response = await http.get(
        Uri.parse('${apiService.baseUrl}/api/interview/audio/$questionId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final audioBytes = base64.decode(data['audio']);
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/question_$questionId.mp3');
        await file.writeAsBytes(audioBytes);
        await audioPlayer.play(DeviceFileSource(file.path));
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to play question: $e');
    } finally {
      isPlaying(false);
    }
  }

  Future<void> startRecording() async {
    try {
      isRecording(true);
      transcript.value = '';
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/interview_answer.wav';
      await recorder.startRecorder(toFile: path);
    } catch (e) {
      Get.snackbar('Error', 'Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      isRecording(false);
      final path = await recorder.stopRecorder();
      if (path == null) {
        Get.snackbar('Error', 'Recording path is null');
        return;
      }
      await submitAnswer(File(path));
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop recording: $e');
    }
  }

  Future<void> submitAnswer(File audioFile) async {
    try {
      isLoading(true);

      final audioBytes = await audioFile.readAsBytes();
      final audioBase64 = base64Encode(audioBytes);

      final speechResult = await apiService.analyzeSpeech(audioFile);
      if (speechResult['status'] == 'success') {
        transcript.value = speechResult['transcript'];
      }

      final response = await http.post(
        Uri.parse('${apiService.baseUrl}/api/interview/submit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'session_id': sessionId.value,
          'answer_text': transcript.value,
          'audio_answer': audioBase64,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        evaluationResult.value = data['evaluation'];

        final score = evaluationResult['overall_score'] ?? 0;
        if (score >= 80) {
          hrdEmoji.value = '😊';
        } else if (score >= 60) {
          hrdEmoji.value = '😐';
        } else {
          hrdEmoji.value = '😞';
        }

        if (data['interview_completed'] == true) {
          interviewCompleted.value = true;
          overallScore.value = data['overall_score'] ?? 0;
          await getInterviewResults();
        } else {
          currentQuestionIndex.value++;
          final nextQuestion = await http.get(
            Uri.parse(
              '${apiService.baseUrl}/api/interview/next-question/${sessionId.value}',
            ),
          );

          if (nextQuestion.statusCode == 200) {
            final nextData = jsonDecode(nextQuestion.body);
            currentQuestion.value = nextData['question'];
            currentQuestionId.value = nextData['question_id'];
            await playQuestionAudio(currentQuestionId.value);
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to submit answer: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> getInterviewResults() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse(
          '${apiService.baseUrl}/api/interview/results/${sessionId.value}',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        evaluationResult.value = data['results'];
        overallScore.value = data['results']['overall_score'] ?? 0;
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to get results: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() async {
    try {
      if (recorder.isRecording) {
        await recorder.stopRecorder();
      }
      await recorder.closeRecorder();
    } catch (e) {
      print('Error closing recorder: $e');
    }
    audioPlayer.dispose();
    super.onClose();
  }
}
