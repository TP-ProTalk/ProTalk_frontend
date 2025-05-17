import 'package:flutter/material.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';

class TestScreen extends StatefulWidget {
  final String mode;
  final String theme;
  final String testNumber;

  const TestScreen({
    super.key,
    required this.mode,
    required this.theme,
    required this.testNumber,
  });

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _test;
  List<Map<String, dynamic>> _questions = [];
  Map<String, String> _answers = {};
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTest();
  }

  Future<void> _loadTest() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final test = await _apiService.getTestById(token, widget.testNumber);
      final questions =
          await _apiService.getTestQuestions(token, widget.testNumber);

      if (questions.isEmpty) {
        throw Exception('Тест не содержит вопросов');
      }

      // Проверяем структуру данных
      for (var question in questions) {
        if (question['answers'] == null ||
            !(question['answers'] is List) ||
            (question['answers'] as List).isEmpty) {
          throw Exception('Вопрос ${question['id']} не содержит ответов');
        }
      }

      setState(() {
        _test = test;
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    setState(() {
      _answers[_questions[_currentQuestionIndex]['id']] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  void _submitTest() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final answers = _questions.map((question) {
        return {
          'question_id': question['id'],
          'answer': _answers[question['id']] ?? '',
        };
      }).toList();

      final result = await _apiService.submitTest(
        token,
        int.parse(widget.testNumber),
        answers,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Тест завершен! Результат: ${result['score']}'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при отправке теста: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF3EFE9),
        appBar: AppBar(
          title: Text('${widget.mode} - ${widget.theme}'),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 127, 113, 179),
          elevation: 1,
        ),
        body: const Center(
          child: Text(
            'Нет доступных вопросов',
            style: TextStyle(fontSize: 18, color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        title: Text('${widget.mode} - ${widget.theme}'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 127, 113, 179),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Вопрос ${_currentQuestionIndex + 1} из ${_questions.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _questions[_currentQuestionIndex]['question'] ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ...List.generate(
                        (_questions[_currentQuestionIndex]['answers'] as List?)
                                ?.length ??
                            0,
                        (index) {
                          final answers = _questions[_currentQuestionIndex]
                              ['answers'] as List?;
                          if (answers == null || index >= answers.length) {
                            return const SizedBox.shrink();
                          }
                          final answer = answers[index];
                          final isSelected = _answers[
                                  _questions[_currentQuestionIndex]['id']] ==
                              answer;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: () => _selectAnswer(answer),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color.fromARGB(255, 127, 113, 179)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color.fromARGB(
                                            255, 127, 113, 179)
                                        : Colors.grey.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isSelected
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        answer,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: _currentQuestionIndex > 0
                                ? _previousQuestion
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 127, 113, 179),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                            ),
                            child: const Text('Назад'),
                          ),
                          if (_currentQuestionIndex < _questions.length - 1)
                            ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 127, 113, 179),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Следующий'),
                            )
                          else
                            ElevatedButton(
                              onPressed: _submitTest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 127, 113, 179),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text('Завершить тест'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
