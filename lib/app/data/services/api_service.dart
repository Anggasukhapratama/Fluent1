import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _accessToken;
  static String? _refreshToken;
  final String baseUrl = 'http://16.16.22.225:5000';

  // Initialize with saved tokens
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  // Save tokens to shared preferences
  static Future<void> _saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
    _accessToken = accessToken;
    _refreshToken = refreshToken;
  }

  // Clear tokens on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _accessToken = null;
    _refreshToken = null;
  }

  // Refresh access token
  Future<bool> refreshToken() async {
    try {
      if (_refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('$baseUrl/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': _refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        await _saveTokens(_accessToken!, _refreshToken!);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Register user
  Future<Map<String, dynamic>> register(
    String email,
    String username,
    String password,
    String gender,
    String occupation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'username': username,
          'password': password,
          'gender': gender,
          'occupation': occupation,
        }),
      );

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Login user
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final result = _handleResponse(response);
      if (result['status'] == 'success') {
        await _saveTokens(result['access_token'], result['refresh_token']);
      }
      return result;
    } catch (e) {
      return _handleError(e);
    }
  }

  // Analyze Realtime with JWT
  Future<Map<String, dynamic>> analyzeRealtime(String base64Image) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/analyze_realtime'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'frame': base64Image}),
      );

      // If token expired, try refreshing
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.post(
            Uri.parse('$baseUrl/analyze_realtime'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode({'frame': base64Image}),
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // Analyze Speech
  Future<Map<String, dynamic>> analyzeSpeech(File audioFile) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/analyze_speech'),
      )..headers['Authorization'] = 'Bearer $_accessToken';

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioFile.path,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      // Handle token refresh if needed
      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl/analyze_speech'),
          )..headers['Authorization'] = 'Bearer $_accessToken';

          request.files.add(
            await http.MultipartFile.fromPath(
              'audio',
              audioFile.path,
              contentType: MediaType('audio', 'wav'),
            ),
          );

          response = await request.send();
          responseData = await response.stream.bytesToString();
        }
      }

      return _handleResponse(http.Response(responseData, response.statusCode));
    } catch (e) {
      return _handleError(e);
    }
  }

  // Interview Management
  Future<Map<String, dynamic>> startInterview(String category) async {
    return _authenticatedPost('$baseUrl/api/interview/start', {
      'category': category,
    });
  }

  Future<Map<String, dynamic>> submitAnswer(
    String sessionId,
    String answerText,
    String? audioBase64,
  ) async {
    return _authenticatedPost('$baseUrl/api/interview/submit', {
      'session_id': sessionId,
      'answer_text': answerText,
      if (audioBase64 != null) 'audio_answer': audioBase64,
    });
  }

  Future<Map<String, dynamic>> getInterviewResults(String sessionId) async {
    return _authenticatedGet('$baseUrl/api/interview/results/$sessionId');
  }

  // Helper methods
  Future<Map<String, dynamic>> _authenticatedPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      var response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_accessToken',
            },
            body: jsonEncode(body),
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> _authenticatedGet(String url) async {
    try {
      var response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (refreshed) {
          response = await http.get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $_accessToken'},
          );
        }
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'status': 'fail',
        'message': 'Error ${response.statusCode}: ${response.body}',
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic e) {
    return {'status': 'fail', 'message': 'Network error: ${e.toString()}'};
  }
}
