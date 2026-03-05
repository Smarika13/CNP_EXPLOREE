import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../models/chat_message.dart';

class MessageBubble extends StatefulWidget {
  final ChatMessage message;
  final Function(String) onSuggestionTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.onSuggestionTap,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
  /// Fixes all known backend formatting issues before rendering:
  /// 1. Inline bullets: "• Tiger • Lion • Bear" → separate lines
  /// 2. Ensure bullet lines always start with "- " for markdown
  /// 3. Collapse excessive blank lines
  String _preprocessText(String text) {
    // Step 1: Split inline bullets onto separate lines
    // Handles "• Tiger • Lion" and "- Tiger - Lion" on one line
    String result = text.replaceAllMapped(
      RegExp(r'\s*[•]\s*'),
          (match) => '\n- ',
    );

    // Step 2: Split lines and clean each one
    final lines = result.split('\n');
    final cleaned = <String>[];

    for (var line in lines) {
      line = line.trim();
      if (line.isEmpty) {
        // Allow at most one blank line between paragraphs
        if (cleaned.isNotEmpty && cleaned.last.isNotEmpty) {
          cleaned.add('');
        }
        continue;
      }

      // Normalize bullet variants (*, •, –, —) to markdown "- "
      if (RegExp(r'^[•\*–—]\s*').hasMatch(line)) {
        line = '- ' + line.replaceFirst(RegExp(r'^[•\*–—]\s*'), '');
      }

      cleaned.add(line);
    }

    // Remove trailing blank lines
    while (cleaned.isNotEmpty && cleaned.last.isEmpty) {
      cleaned.removeLast();
    }

    return cleaned.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final bool isUser = widget.message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      child: Column(
        crossAxisAlignment:
        isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF2C5F2E) : const Color(0xFFFEFCF8),
              border: isUser ? null : Border.all(color: const Color(0xFFDDD0B8), width: 1),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft:
                isUser ? const Radius.circular(16) : Radius.zero,
                bottomRight:
                isUser ? Radius.zero : const Radius.circular(16),
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5)
              ],
            ),
            child: _buildMessageContent(isUser),
          ),

          // Suggestion chips
          if (!isUser && widget.message.suggestions != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: widget.message.suggestions!
                    .map((s) => ActionChip(
                  label: Text(s,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF2D5016))),
                  backgroundColor: const Color(0xFFFFF8EE),
                  side: const BorderSide(color: Color(0xFFC8873A)),
                  onPressed: () => widget.onSuggestionTap(s),
                ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(bool isUser) {
    final processedText = _preprocessText(widget.message.text);

    // Animate only bot messages that haven't been animated yet
    if (!isUser && !widget.message.isAnimated) {
      return DefaultTextStyle(
        style: const TextStyle(
            fontSize: 15, color: Colors.black87, height: 1.4),
        child: AnimatedTextKit(
          totalRepeatCount: 1,
          displayFullTextOnTap: true,
          onFinished: () =>
              setState(() => widget.message.isAnimated = true),
          animatedTexts: [
            TypewriterAnimatedText(
              processedText,
              speed: const Duration(milliseconds: 18), // slightly faster
            ),
          ],
        ),
      );
    }

    return MarkdownBody(
      data: processedText,
      softLineBreak: true,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4),
        h3: TextStyle(
            fontWeight: FontWeight.bold,
            color: isUser ? Colors.white : const Color(0xFF1B4332)),
        listBullet: TextStyle(
            color: isUser ? Colors.white : const Color(0xFF2C5F2E), fontSize: 15),
        // Spacing between list items
        listIndent: 16,
      ),
    );
  }
}