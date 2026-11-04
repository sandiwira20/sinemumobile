import 'dart:convert';
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../models/chatbot_message_model.dart';

class ChatbotService {
  ChatbotService({
    http.Client? httpClient,
    FlutterSecureStorage? storage,
  })  : _httpClient = httpClient ?? http.Client(),
        _storage = storage ?? const FlutterSecureStorage();

  final http.Client _httpClient;
  final FlutterSecureStorage _storage;

  static const String _sessionKey = 'sinemu_chatbot_session_id';

  Future<String> getSessionId() async {
    String? sessionId = await _storage.read(key: _sessionKey);
    if (sessionId == null || sessionId.trim().isEmpty) {
      final random = Random().nextInt(999999);
      sessionId = 'mobile_${DateTime.now().millisecondsSinceEpoch}_$random';
      await _storage.write(key: _sessionKey, value: sessionId);
    }
    return sessionId;
  }

  Future<List<ChatbotMessageModel>> getHistory() async {
    try {
      final sessionId = await getSessionId();
      final uri = Uri.parse('${ApiConfig.baseUrl}/chatbot/history')
          .replace(queryParameters: {'session_id': sessionId});

      final response = await _httpClient.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic> && data['messages'] is List) {
          final list = data['messages'] as List;
          return list
              .map((item) => ChatbotMessageModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (_) {}
    return [];
  }

  Future<String> sendMessage(String message) async {
    final sessionId = await getSessionId();
    final uri = Uri.parse('${ApiConfig.baseUrl}/chatbot/send');

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'message': message.trim(),
          'session_id': sessionId,
        }),
      ).timeout(const Duration(seconds: 30));

      final data = jsonDecode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data['message']?.toString() ??
            'Halo! Ada yang bisa saya bantu terkait Sinemu? 😊';
      } else {
        return data['message']?.toString() ??
            'Maaf, terjadi gangguan pada sistem kami. Coba lagi nanti ya! 🙏';
      }
    } catch (e) {
      return 'Maaf, koneksi ke server sedang terganggu. Periksa koneksi internet kamu ya! 🌐';
    }
  }

  Future<void> resetConversation() async {
    try {
      final sessionId = await getSessionId();
      final uri = Uri.parse('${ApiConfig.baseUrl}/chatbot/new');
      await _httpClient.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'session_id': sessionId}),
      ).timeout(const Duration(seconds: 10));
    } catch (_) {}

    final random = Random().nextInt(999999);
    final newSessionId = 'mobile_${DateTime.now().millisecondsSinceEpoch}_$random';
    await _storage.write(key: _sessionKey, value: newSessionId);
  }
}

