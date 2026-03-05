import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;

class ChatbotService {
  static const String baseUrl = 'https://ai-part-h3xq.onrender.com/api/v1';

  Future<ChatResponse> sendMessage({
    required String question,
    required String sessionId,
    bool includeSuggestions = true,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/chat');
      final response = await http
          .post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Session-ID': sessionId,
        },
        body: jsonEncode({
          'query': question,
          'session_id': sessionId,
          'include_suggestions': includeSuggestions,
          'use_emojis': false,
        }),
      )
          .timeout(
        const Duration(seconds: 120),
        onTimeout: () =>
        throw Exception('Request timeout. Is the backend running?'),
      );

      // ✅ Backend now always returns Flutter-safe JSON — parse regardless of status
      final data = jsonDecode(response.body);
      return ChatResponse.fromJson(data);

    } catch (e, stackTrace) {
      developer.log('Error in sendMessage', error: e, stackTrace: stackTrace);
      // Safe fallback — UI never crashes
      return ChatResponse(
        answer: 'Connection failed. Please check your network and try again. 🙏',
        suggestions: const [
          'What animals can I see?',
          'Tell me about tigers',
          'Best time to visit',
        ],
      );
    }
  }

  /// Check if server is reachable (status 200).
  /// Render free tier can take 60-90s to wake from sleep — retries 12×8s=96s.
  Future<bool> checkHealth() async {
    for (int i = 0; i < 12; i++) {
      try {
        final response = await http
            .get(Uri.parse('$baseUrl/health'))
            .timeout(const Duration(seconds: 10));
        if (response.statusCode == 200) return true;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 8));
    }
    return false;
  }

  /// Check if RAG is fully initialized and ready to answer questions.
  Future<bool> checkReady() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['ready'] == true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Poll health until backend is fully ready (RAG index loaded).
  /// Call this on startup before enabling chat input.
  Future<void> waitUntilReady({
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 15,
    void Function(int attempt)? onProgress,
  }) async {
    for (int i = 1; i <= maxAttempts; i++) {
      onProgress?.call(i);
      final ready = await checkReady();
      if (ready) return;
      await Future.delayed(interval);
    }
    // Give up after maxAttempts — app proceeds anyway
  }

  /// Clear conversation memory for a specific session.
  Future<void> clearMemory({required String sessionId}) async {
    try {
      final response = await http
          .post(
        Uri.parse('$baseUrl/clear-memory'),
        headers: {
          'Content-Type': 'application/json',
          'X-Session-ID': sessionId,
        },
        body: jsonEncode({'session_id': sessionId}),
      )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);
      developer.log('Memory clear: ${data['status']} — ${data['message']}');
    } catch (e) {
      developer.log('Clear failed', error: e);
    }
  }
}


// ── Response Model ────────────────────────────────────────────────────────────

class ChatResponse {
  final String answer;
  final List<String> sources;
  final List<String> suggestions;
  final String displayType;    // "text", "list", "bare_list"
  final String? sessionId;     // echoed back from backend

  ChatResponse({
    required this.answer,
    this.sources      = const [],
    this.suggestions  = const [],
    this.displayType  = 'text',
    this.sessionId,
  });

  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    return ChatResponse(
      answer: json['answer'] ?? json['response'] ?? 'No answer received.',

      sources: (json['sources'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],

      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((e) => _parseSuggestion(e))
          .where((s) => s.isNotEmpty)
          .toList() ??
          [],

      displayType: json['display_type']?.toString() ?? 'text',
      sessionId:   json['session_id']?.toString(),
    );
  }

  /// Safely converts any suggestion format into a displayable string.
  static String _parseSuggestion(dynamic e) {
    if (e is Map) {
      return e['text']?.toString().trim() ?? '';
    }
    if (e is String) {
      final trimmed = e.trim();
      try {
        final parsed = jsonDecode(trimmed);
        if (parsed is Map) return parsed['text']?.toString().trim() ?? trimmed;
      } catch (_) {}
      final match = RegExp(r"""['"]text['"]\s*:\s*['"]([^'"]+)['"]""")
          .firstMatch(trimmed);
      if (match != null) return match.group(1)?.trim() ?? trimmed;
      return trimmed;
    }
    return e.toString();
  }
}