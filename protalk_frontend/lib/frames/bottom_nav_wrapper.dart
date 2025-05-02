import 'package:flutter/material.dart';
import 'knowledgebase.dart';
import 'mode_test_screen.dart';
import 'HistoryScreen.dart';
import 'user_screen.dart';
import 'interview_screen.dart';

class BottomNavWrapper extends StatefulWidget {
  const BottomNavWrapper({super.key});

  @override
  State<BottomNavWrapper> createState() => _BottomNavWrapperState();
}

class _BottomNavWrapperState extends State<BottomNavWrapper> {
  int _currentIndex = 1;

  final List<Widget> _pages = const [
    Knowledgebase(),
    ModeTestScreen(),
    InterviewScreen(),
    HistoryScreen(),
    UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text('ProTalk', style: TextStyle(fontSize: 24)),
        backgroundColor: Colors.black45,
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Color(0xFF4C4872),
        unselectedItemColor: Colors.black54,
        backgroundColor: const Color(0xFFE7DFCF),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'База'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Тест'),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy),
            label: 'Собес',
          ), // ✅
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
