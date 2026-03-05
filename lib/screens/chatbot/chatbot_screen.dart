import 'dart:io';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../shared/services/chatbot_service.dart';
import '../../models/chat_message.dart';
import '../../shared/widgets/message_bubble.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ChatbotService       _chatbotService    = ChatbotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController      _scrollController  = ScrollController();
  final List<ChatMessage>     _messages          = [];

  bool   _isLoading        = false;
  bool   _isBackendHealthy = false;
  bool   _isBackendReady   = false;
  String _statusText       = 'Connecting...';

  // ── Speech to text ────────────────────────────────────────────────────────
  final SpeechToText _speech       = SpeechToText();
  bool               _isListening  = false;
  bool               _speechReady  = false;
  String             _speechLocale = 'en_US'; // 'en_US' or 'ne_NP'

  // ── Session ID: unique per device install ─────────────────────────────────
  late final String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = _generateSessionId();
    _initBackend();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final available = await _speech.initialize(
      onError: (_) => setState(() => _isListening = false),
    );
    if (mounted) setState(() => _speechReady = available);
  }

  Future<void> _toggleListening() async {
    if (!_speechReady) {
      _showSnackbar('Microphone not available on this device', Colors.orange);
      return;
    }
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    setState(() => _isListening = true);
    await _speech.listen(
      localeId: _speechLocale,
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            _messageController.text = result.recognizedWords;
            _isListening = false;
          });
        } else {
          _messageController.text = result.recognizedWords;
        }
      },
      onSoundLevelChange: null,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
    );
  }

  void _toggleLocale() {
    setState(() {
      _speechLocale = _speechLocale == 'en_US' ? 'ne_NP' : 'en_US';
    });
    _showSnackbar(
      _speechLocale == 'ne_NP' ? 'Voice: नेपाली' : 'Voice: English',
      Colors.green,
    );
  }

  /// Generate a unique session ID for this app install.
  String _generateSessionId() {
    final platform = Platform.operatingSystem;
    final unique = DateTime.now().millisecondsSinceEpoch.toString();
    return '${platform}_$unique';
  }

  // ── Backend init: poll until RAG is fully ready ────────────────────────────
  Future<void> _initBackend() async {
    setState(() {
      _statusText = 'Connecting to backend...';
      _isBackendHealthy = false;
      _isBackendReady   = false;
    });

    // Step 1: Wait until backend is reachable
    final reachable = await _chatbotService.checkHealth();
    if (!mounted) return;

    if (!reachable) {
      setState(() {
        _isBackendHealthy = false;
        _isBackendReady   = false;
        _statusText       = 'Backend offline';
      });
      _showSnackbar('⚠️ Backend offline — is the server running?', Colors.orange);
      return;
    }

    setState(() {
      _isBackendHealthy = true;
      _statusText       = 'Loading AI model...';
    });

    // Step 2: Poll until RAG is fully initialized
    await _chatbotService.waitUntilReady(
      interval:    const Duration(seconds: 5),
      maxAttempts: 24,
      onProgress:  (attempt) {
        if (mounted) {
          setState(() => _statusText = 'Loading AI model... ($attempt)');
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isBackendReady = true;
      _statusText     = 'System Ready';
    });

    _showSnackbar('✅ Connected to CNP Backend', Colors.green);
    _addWelcomeMessage();
  }

  // ── Manual health recheck (refresh button) ────────────────────────────────
  Future<void> _checkBackendHealth() async {
    setState(() => _statusText = 'Reconnecting...');
    await _initBackend();
  }

  // ── Welcome message ────────────────────────────────────────────────────────
  void _addWelcomeMessage() {
    if (_messages.any((m) => m.id == 'welcome')) return;
    setState(() {
      _messages.add(ChatMessage(
        id: 'welcome',
        text:
        '### 👋 Welcome to Chitwan National Park Assistant\n\n'
            'How can I help you today? You can ask about:\n'
            '* **Wildlife** sightings\n'
            '* **Rules** & Safety\n'
            '* **Entry Fees** and Activity timings',
        isUser: false,
        timestamp: DateTime.now(),
        isAnimated: true,
        suggestions: const [
          'Tiger Sightings',
          'Jeep Safari Rules',
          'Best time to visit',
        ],
      ));
    });
  }

  // ── Send message ───────────────────────────────────────────────────────────
  Future<void> _sendMessage({String? suggestedText}) async {
    final text = suggestedText ?? _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    if (!_isBackendReady) {
      _showSnackbar('Backend is still loading. Please wait...', Colors.orange);
      return;
    }

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    final response = await _chatbotService.sendMessage(
      question:           text,
      sessionId:          _sessionId,
      includeSuggestions: true,
    );

    if (!mounted) return;

    final botMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response.answer,
      isUser: false,
      timestamp: DateTime.now(),
      sources: response.sources,
      suggestions: response.suggestions,
      isAnimated: false,
    );

    setState(() {
      _messages.add(botMessage);
      _isLoading = false;
    });
    _scrollToBottom();
  }

  // ── Clear memory ───────────────────────────────────────────────────────────
  Future<void> _clearMemory() async {
    await _chatbotService.clearMemory(sessionId: _sessionId);
    if (!mounted) return;
    setState(() => _messages.clear());
    _addWelcomeMessage();
    _showSnackbar('🗑️ Conversation cleared', Colors.green);
  }

  // ── UI helpers ─────────────────────────────────────────────────────────────
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackbar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Status indicator color ─────────────────────────────────────────────────
  Color get _statusColor {
    if (_isBackendReady)   return Colors.green;
    if (_isBackendHealthy) return Colors.orange;
    return Colors.red;
  }

  String get _statusEmoji {
    if (_isBackendReady)   return '🟢';
    if (_isBackendHealthy) return '🟡';
    return '🔴';
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F0E8),
      appBar: AppBar(
        elevation: 2,
        backgroundColor: const Color(0xFF1B4332),
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CNP AI Assistant',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
            ),
            Text(
              '$_statusEmoji $_statusText',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear conversation',
            onPressed: _isBackendReady ? _clearMemory : null,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reconnect',
            onPressed: _checkBackendHealth,
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Loading banner while backend initializes ───────────────────────
          if (!_isBackendReady)
            Container(
              width: double.infinity,
              color: _isBackendHealthy
                  ? Colors.orange[100]
                  : Colors.red[100],
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
              child: Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _statusColor,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _statusText,
                    style: TextStyle(
                      fontSize: 12,
                      color: _statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index],
                  onSuggestionTap: (selectedText) =>
                      _sendMessage(suggestedText: selectedText),
                );
              },
            ),
          ),
          if (_isLoading)
            const LinearProgressIndicator(
              backgroundColor: Colors.transparent,
              color: Color(0xFFC8873A),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    final bool inputEnabled = !_isLoading && _isBackendReady;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Color(0xFFFEFCF8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Language toggle row (only shown when speech is available) ────
            if (_speechReady)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _toggleLocale,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6, right: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFC8873A)),
                      borderRadius: BorderRadius.circular(12),
                      color: const Color(0xFFFFF8EE),
                    ),
                    child: Text(
                      _speechLocale == 'ne_NP' ? 'Voice: नेपाली' : 'Voice: English',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF2D5016)),
                    ),
                  ),
                ),
              ),
            // ── Input row ───────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: inputEnabled && !_isListening,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      hintText: _isListening
                          ? (_speechLocale == 'ne_NP'
                              ? 'सुन्दैछ...'
                              : 'Listening...')
                          : (_isBackendReady
                              ? 'Ask about wildlife or rules...'
                              : 'Waiting for backend...'),
                      filled: true,
                      fillColor: _isListening
                          ? const Color(0xFFFFF8EE)
                          : const Color(0xFFF0EBE1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // ── Mic button ───────────────────────────────────────────────
                if (_speechReady)
                  GestureDetector(
                    onTap: inputEnabled ? _toggleListening : null,
                    child: CircleAvatar(
                      backgroundColor: _isListening
                          ? Colors.red[700]
                          : (inputEnabled ? const Color(0xFFD4A96A) : Colors.grey.shade200),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: _isListening
                            ? Colors.white
                            : (inputEnabled ? const Color(0xFF1B4332) : Colors.grey),
                        size: 20,
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                // ── Send button ──────────────────────────────────────────────
                GestureDetector(
                  onTap: (_isLoading || !_isBackendReady || _isListening)
                      ? null
                      : _sendMessage,
                  child: CircleAvatar(
                    backgroundColor:
                        (_isLoading || !_isBackendReady || _isListening)
                            ? Colors.grey
                            : const Color(0xFF1B4332),
                    child: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
