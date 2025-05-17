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
  // Временные данные для тестирования
  final Map<String, Map<String, List<Map<String, dynamic>>>> _questions = {
    'Soft': {
      'Тема 1': [
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
        {
          'question':
              'Какой паттерн проектирования используется для определения семейства алгоритмов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Strategy',
        },
        {
          'question':
              'Какой паттерн проектирования используется для создания объектов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Factory Method',
        },
      ],
      'Тема 2': [
        {
          'question':
              'Какой паттерн проектирования используется для уведомления об изменениях?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Observer',
        },
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
        {
          'question':
              'Какой паттерн проектирования используется для определения семейства алгоритмов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Strategy',
        },
      ],
      'Тема 3': [
        {
          'question':
              'Какой паттерн проектирования используется для создания объектов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Factory Method',
        },
        {
          'question':
              'Какой паттерн проектирования используется для уведомления об изменениях?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Observer',
        },
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
      ],
    },
    'Hard': {
      'Тема A': [
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
        {
          'question':
              'Какой паттерн проектирования используется для определения семейства алгоритмов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Strategy',
        },
        {
          'question':
              'Какой паттерн проектирования используется для создания объектов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Factory Method',
        },
      ],
      'Тема B': [
        {
          'question':
              'Какой паттерн проектирования используется для уведомления об изменениях?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Observer',
        },
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
        {
          'question':
              'Какой паттерн проектирования используется для определения семейства алгоритмов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Strategy',
        },
      ],
      'Тема C': [
        {
          'question':
              'Какой паттерн проектирования используется для создания объектов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Factory Method',
        },
        {
          'question':
              'Какой паттерн проектирования используется для уведомления об изменениях?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Observer',
        },
        {
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correctAnswer': 'Singleton',
        },
      ],
    },
  };

  String questionText = '';
  List<String> answers = [];
  String correctAnswer = '';
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  void _loadQuestion() {
    try {
      final modeQuestions = _questions[widget.mode];
      if (modeQuestions == null) {
        _setErrorState('Режим не найден');
        return;
      }

      final themeQuestions = modeQuestions[widget.theme];
      if (themeQuestions == null) {
        _setErrorState('Тема не найдена');
        return;
      }

      if (widget.questionNumber < 1 ||
          widget.questionNumber > themeQuestions.length) {
        _setErrorState('Вопрос не найден');
        return;
      }

      final questionData = themeQuestions[widget.questionNumber - 1];
      if (questionData == null) {
        _setErrorState('Данные вопроса не найдены');
        return;
      }

      setState(() {
        questionText = questionData['question'] as String;
        answers = List<String>.from(questionData['answers'] as List);
        correctAnswer = questionData['correctAnswer'] as String;
      });
    } catch (e) {
      _setErrorState('Ошибка загрузки вопроса: ${e.toString()}');
    }
  }

  void _setErrorState(String errorMessage) {
    setState(() {
      questionText = errorMessage;
      answers = ['Ошибка загрузки вопроса'];
      correctAnswer = 'Ошибка загрузки вопроса';
    });
  }

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
                  onPressed: selectedAnswer == null
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
