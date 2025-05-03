import 'package:flutter/material.dart';

class QuestionScreen extends StatefulWidget {
  final String mode;
  final String theme;
  final int questionNumber;

  const QuestionScreen({
    Key? key,
    required this.mode,
    required this.theme,
    required this.questionNumber,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final String questionText =
      'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?';

  final List<String> answers = [
    'Factory Method',
    'Observer',
    'Singleton',
    'Strategy',
  ];

  final String correctAnswer = 'Singleton';
  String? selectedAnswer;

  void _handleAnswerTap(String answer) {
    if (selectedAnswer == null) {
      setState(() {
        selectedAnswer = answer;
      });
    }
  }

  Color _getButtonColor(String answer) {
    if (selectedAnswer == null) {
      return const Color(0xFF7F71B3);
    }

    if (answer == correctAnswer) {
      return Colors.green;
    }

    if (answer == selectedAnswer) {
      return Colors.red;
    }

    return const Color(0xFF7F71B3).withOpacity(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1EFEA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1EFEA),
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${widget.mode} - ${widget.theme}',
          style: const TextStyle(
            color: Color.fromARGB(255, 76, 72, 114),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 76, 72, 114)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Вопрос ${widget.questionNumber}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 127, 113, 179),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    questionText,
                    style: const TextStyle(fontSize: 18, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ...answers.map(
              (answer) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton(
                  onPressed:
                      selectedAnswer == null
                          ? () => _handleAnswerTap(answer)
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getButtonColor(answer),
                    minimumSize: const Size(double.infinity, 60),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black38,
                  ),
                  child: Text(
                    answer,
                    style: const TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
