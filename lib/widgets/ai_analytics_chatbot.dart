import 'package:flutter/material.dart';

import '../services/ai_service.dart';

class AiAnalyticsChatbot extends StatefulWidget {
  const AiAnalyticsChatbot({
    super.key,
    required this.role,
    required this.documents,
  });

  final String role;
  final List<Map<String, dynamic>> documents;

  @override
  State<AiAnalyticsChatbot> createState() => _AiAnalyticsChatbotState();
}

class _AiAnalyticsChatbotState extends State<AiAnalyticsChatbot> {
  final _controller = TextEditingController();
  final _messages = <_ChatMessage>[
    const _ChatMessage(
      sender: "AIQ",
      text:
          "Ask about workload, revenue, employees, company health, or assignment risks.",
      isUser: false,
    ),
  ];
  bool _isThinking = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return Align(
                alignment:
                    message.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 520),
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isThinking) const LinearProgressIndicator(minHeight: 2),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  minLines: 1,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Ask AIQ analytics...",
                    prefixIcon: Icon(Icons.auto_awesome),
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: _isThinking ? null : _send,
                icon: const Icon(Icons.send),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _send() async {
    final question = _controller.text.trim();
    if (question.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(sender: "You", text: question, isUser: true));
      _controller.clear();
      _isThinking = true;
    });

    final answer = await AiService().askAnalytics(
      question: question,
      role: widget.role,
      documents: widget.documents,
    );

    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(sender: "AIQ", text: answer, isUser: false));
      _isThinking = false;
    });
  }
}

class _ChatMessage {
  final String sender;
  final String text;
  final bool isUser;

  const _ChatMessage({
    required this.sender,
    required this.text,
    required this.isUser,
  });
}
