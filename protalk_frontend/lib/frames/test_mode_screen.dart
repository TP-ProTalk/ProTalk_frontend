import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/theme.dart';

class TestModeScreen extends StatefulWidget {
  const TestModeScreen({Key? key}) : super(key: key);

  @override
  State<TestModeScreen> createState() => _TestModeScreenState();
}

class _TestModeScreenState extends State<TestModeScreen> {
  final _apiService = ApiService();
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _isLoading = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final questions = await _apiService.getQuestions();
      setState(() {
        _questions = questions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки вопросов: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text('Тестовый режим'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? const Center(child: Text('Нет доступных вопросов'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Вопрос ${_currentQuestionIndex + 1} из ${_questions.length}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              _questions[_currentQuestionIndex]['question'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _questions[_currentQuestionIndex]
                                  ['answers']
                              .length,
                          itemBuilder: (context, index) {
                            final answer = _questions[_currentQuestionIndex]
                                ['answers'][index];
                            final isSelected = _selectedAnswer == answer;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAnswer = answer;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primaryColor.withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        isSelected
                                            ? Icons.radio_button_checked
                                            : Icons.radio_button_unchecked,
                                        color: isSelected
                                            ? AppTheme.primaryColor
                                            : Colors.black54,
                                      ),
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Text(
                                          answer,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : Colors.black87,
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
                      ),
                      const SizedBox(height: 16.0),
                      SizedBox(
                        height: 48.0,
                        child: ElevatedButton(
                          onPressed:
                              _selectedAnswer == null ? null : _handleAnswer,
                          style: AppTheme.primaryButtonStyle,
                          child: Text(
                            _currentQuestionIndex == _questions.length - 1
                                ? 'Завершить'
                                : 'Следующий вопрос',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Future<void> _handleAnswer() async {
    if (_selectedAnswer == null) return;

    final isCorrect =
        _selectedAnswer == _questions[_currentQuestionIndex]['correctAnswer'];

    if (isCorrect) {
      setState(() {
        _score++;
      });
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
      });
    } else {
      // TODO: Показать результаты
    }
  }
}
