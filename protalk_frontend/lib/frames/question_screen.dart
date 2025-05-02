import 'package:flutter/material.dart';

class QuestionScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$mode - $theme - Вопрос $questionNumber')),
      body: Center(
        child: Text(
          'Это экран вопроса $questionNumber в теме "$theme" режима $mode',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
