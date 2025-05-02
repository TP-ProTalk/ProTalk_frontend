import 'package:flutter/material.dart';
import 'knowledgebase.dart';
import 'user_screen.dart';
import 'HistoryScreen.dart';
import 'mode_test_screen.dart';
import 'interview_screen.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Knowledgebase(),
    const ModeTestScreen(),
    const InterviewScreen(),
    const HistoryScreen(),
    const UserScreen(),
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
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder:
            (child, animation) =>
                FadeTransition(opacity: animation, child: child),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: Colors.black45,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Знания'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Тесты'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy), label: 'Собес.'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'История'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
