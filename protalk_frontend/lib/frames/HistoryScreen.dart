import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInterviewCard(
            context,
            title: 'Soft Skills',
            score: 10,
            details: const [
              {'title': 'Коммуникация', 'count': '3 статьи'},
              {'title': 'Работа в команде', 'count': '5 статей'},
              {'title': 'Эмпатия', 'count': '2 статьи'},
            ],
          ),
          const SizedBox(height: 16),
          _buildInterviewCard(
            context,
            title: 'Hard Skills',
            score: 7,
            details: const [
              {'title': 'Алгоритмы', 'count': '2 статьи'},
              {'title': 'Базы данных', 'count': '3 статьи'},
              {'title': 'Сети', 'count': '2 статьи'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInterviewCard(
    BuildContext context, {
    required String title,
    required int score,
    required List<Map<String, String>> details,
  }) {
    // Цвет заголовка зависит от типа
    final Color titleColor =
        (title == 'Soft Skills' || title == 'Hard Skills')
            ? const Color.fromARGB(255, 127, 113, 179)
            : Colors.grey;

    return Card(
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: ExpansionTile(
        collapsedIconColor: Colors.black,
        iconColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: titleColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$score / 10',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        children:
            details.map((detail) {
              return ListTile(
                title: Text(
                  detail['title']!,
                  style: const TextStyle(fontSize: 16),
                ),
                trailing: Text(
                  detail['count']!,
                  style: const TextStyle(color: Colors.grey),
                ),
              );
            }).toList(),
      ),
    );
  }
}
