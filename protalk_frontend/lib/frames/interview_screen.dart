import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../styles/theme.dart';

class InterviewScreen extends StatefulWidget {
  const InterviewScreen({Key? key}) : super(key: key);

  @override
  State<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends State<InterviewScreen> {
  final _apiService = ApiService();
  String? _currentQuestion;
  String? _userAnswer;
  bool _isLoading = false;
  int _timeLeft = 300; // 5 минут в секундах
  bool _isTimerRunning = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        title: const Text('Интервью'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isTimerRunning)
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer, color: AppTheme.primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      '${(_timeLeft ~/ 60).toString().padLeft(2, '0')}:${(_timeLeft % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16.0),
            if (_currentQuestion != null)
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
                child: Text(
                  _currentQuestion!,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
              ),
            const SizedBox(height: 16.0),
            if (_currentQuestion != null)
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
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _userAnswer = value;
                    });
                  },
                  maxLines: 5,
                  decoration: AppTheme.textFieldDecoration.copyWith(
                    hintText: 'Введите ваш ответ...',
                  ),
                ),
              ),
            const Spacer(),
            SizedBox(
              height: 48.0,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleNextQuestion,
                style: AppTheme.primaryButtonStyle,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(_currentQuestion == null
                        ? 'Начать'
                        : 'Следующий вопрос'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleNextQuestion() async {
    if (_currentQuestion == null) {
      // Начинаем интервью
      setState(() {
        _isLoading = true;
        _isTimerRunning = true;
      });
      _startTimer();
    } else {
      // Отправляем ответ и получаем следующий вопрос
      if (_userAnswer == null || _userAnswer!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, введите ответ'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
        return;
      }
    }

    try {
      final nextQuestion = await _apiService.getNextQuestion(_userAnswer);
      setState(() {
        _currentQuestion = nextQuestion;
        _userAnswer = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _isTimerRunning) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
            _startTimer();
          } else {
            _isTimerRunning = false;
            // Завершаем интервью
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    super.dispose();
  }
}
