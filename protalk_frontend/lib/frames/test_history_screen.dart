import 'package:flutter/material.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';

class TestHistoryScreen extends StatefulWidget {
  const TestHistoryScreen({super.key});

  @override
  State<TestHistoryScreen> createState() => _TestHistoryScreenState();
}

class _TestHistoryScreenState extends State<TestHistoryScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _history = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final history = await _apiService.getTestHistory(token);

      setState(() {
        _history = history.map((test) {
          return {
            'id': test['id']?.toString() ?? '',
            'test_id': test['test_id']?.toString() ?? '',
            'title': test['title'] ?? 'Без названия',
            'date': test['date'] ?? DateTime.now().toIso8601String(),
            'score': test['score']?.toString() ?? '0',
            'total_questions': test['total_questions']?.toString() ?? '0',
            'correct_answers': test['correct_answers']?.toString() ?? '0',
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text(
          'История тестов',
          style: TextStyle(
            fontFamily: 'Cuyabra',
          ),
        ),
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
              : _history.isEmpty
                  ? const Center(
                      child: Text(
                        'История тестов пуста',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _history.length,
                      itemBuilder: (context, index) {
                        final test = _history[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              test['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cuyabra',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateTime.parse(test['date'])
                                          .toString()
                                          .split('.')[0],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Cuyabra',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.score,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Результат: ${test['score']}%',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Cuyabra',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.question_answer,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Правильных ответов: ${test['correct_answers']} из ${test['total_questions']}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Cuyabra',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.visibility),
                              onPressed: () {
                                // TODO: Навигация к деталям теста
                              },
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
