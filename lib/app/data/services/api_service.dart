import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String? _accessToken;
  static String? _refreshToken;
  final String baseUrl = 'http://192.168.101.186:5000'; // Your Flask API URL

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

  // Save user data to shared preferences
  static Future<void> _saveUserData(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', user['username'] ?? '');
    await prefs.setString('email', user['email'] ?? '');
    await prefs.setString('gender', user['gender'] ?? '');
    await prefs.setString('occupation', user['occupation'] ?? '');
  }

  // Clear tokens and user data on logout
  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('gender');
    await prefs.remove('occupation');
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
      print("Error refreshing token: $e");
      return false;
    }
  }

  // ==================== HRD SIMULATION SERVICES ====================

  Future<Map<String, dynamic>> startHRSimulation(String difficulty) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hr/start_session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'difficulty': difficulty}),
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (!refreshed) throw Exception('Failed to refresh token');
        return startHRSimulation(difficulty);
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> processHRResponse({
    required String audioPath,
    required String sessionId,
    required int questionIndex,
    required String transcript,
  }) async {
    try {
      final audioFile = File(audioPath);
      if (!await audioFile.exists()) {
        return {'status': 'fail', 'message': 'Audio file not found'};
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/hr/process_response'),
      );

      request.headers['Authorization'] = 'Bearer $_accessToken';
      request.fields['session_id'] = sessionId;
      request.fields['question_index'] = questionIndex.toString();
      request.fields['transcript'] = transcript;

      request.files.add(
        await http.MultipartFile.fromPath(
          'audio',
          audioPath,
          contentType: MediaType('audio', 'wav'),
        ),
      );

      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 401) {
        final refreshed = await refreshToken();
        if (!refreshed) throw Exception('Failed to refresh token');
        return processHRResponse(
          audioPath: audioPath,
          sessionId: sessionId,
          questionIndex: questionIndex,
          transcript: transcript,
        );
      }

      return _handleResponse(responseData);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Ends HR simulation session and gets final results
  Future<Map<String, dynamic>> endHRSimulation(String sessionId) async {
    try {
      var response = await http.post(
        Uri.parse('$baseUrl/hr/end_session'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({'session_id': sessionId}),
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (!refreshed) throw Exception('Failed to refresh token');
        response = await http.post(
          Uri.parse('$baseUrl/hr/end_session'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: jsonEncode({'session_id': sessionId}),
        );
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Gets HR simulation history
  Future<Map<String, dynamic>> getHRHistory() async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/hr/history'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (!refreshed) throw Exception('Failed to refresh token');
        response = await http.get(
          Uri.parse('$baseUrl/hr/history'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  /// Gets details of a specific HR session
  Future<Map<String, dynamic>> getHRSessionDetails(String sessionId) async {
    try {
      var response = await http.get(
        Uri.parse('$baseUrl/hr/session/$sessionId'),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshToken();
        if (!refreshed) throw Exception('Failed to refresh token');
        response = await http.get(
          Uri.parse('$baseUrl/hr/session/$sessionId'),
          headers: {'Authorization': 'Bearer $_accessToken'},
        );
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== EXISTING SERVICES ====================

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
        if (result['user'] != null) await _saveUserData(result['user']);
      }
      return result;
    } catch (e) {
      return _handleError(e);
    }
  }

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

      if (response.statusCode == 401) {
        if (!await refreshToken()) throw Exception('Failed to refresh token');
        response = await http.post(
          Uri.parse('$baseUrl/analyze_realtime'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_accessToken',
          },
          body: jsonEncode({'frame': base64Image}),
        );
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> simpanHasilWawancara(
    Map<String, dynamic> results,
    Map<String, dynamic> metrics,
    int durationInSeconds,
    String difficulty,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/save_wawancara'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          'results': results,
          'metrics': metrics,
          'recording_duration': durationInSeconds,
          'difficulty': difficulty,
          'feedback': metrics['feedback'],
        }),
      );

      if (response.statusCode == 401) {
        if (!await refreshToken()) throw Exception('Failed to refresh token');
        return await simpanHasilWawancara(
          results,
          metrics,
          durationInSeconds,
          difficulty,
        );
      }

      return _handleResponse(response);
    } catch (e) {
      return _handleError(e);
    }
  }

  // ==================== HELPER METHODS ====================

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
