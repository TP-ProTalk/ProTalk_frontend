import 'package:flutter/material.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({super.key});

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_Message> _messages = [];
  bool _isLoading = false;

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_Message(text: text, isUser: true));
      _controller.clear();
      _isLoading = true;
    });

    // TODO: Реальная интеграция с GPT API
    await Future.delayed(const Duration(seconds: 2)); // имитация задержки
    const aiResponse =
        'Спасибо за ваш ответ! Расскажите подробнее о вашем опыте работы.';

    setState(() {
      _messages.add(_Message(text: aiResponse, isUser: false));
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1EFEA),
        elevation: 0,
        title: const Text(
          'Собеседование AI',
          style: TextStyle(
            color: Color.fromARGB(255, 76, 72, 114),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 76, 72, 114)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Align(
                  alignment:
                      message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color:
                          message.isUser
                              ? const Color.fromARGB(255, 127, 113, 179)
                              : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(message.isUser ? 16 : 0),
                        bottomRight: Radius.circular(message.isUser ? 0 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        color: message.isUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Введите ваш ответ...',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Color.fromARGB(255, 76, 72, 114),
                  ),
                  tooltip: 'Отправить',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Message {
  final String text;
  final bool isUser;

  _Message({required this.text, required this.isUser});
}
