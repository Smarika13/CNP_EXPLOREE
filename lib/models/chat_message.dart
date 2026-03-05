class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? sources; // Required for backend citations
  final List<String>? suggestions;
  bool isAnimated;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.sources, // This fixes the 'named parameter' error
    this.suggestions,
    this.isAnimated = false,
  });
}