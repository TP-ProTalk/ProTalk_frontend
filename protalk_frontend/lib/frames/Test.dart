import 'package:flutter/material.dart';
import 'knowledgebase.dart';
import 'user_screen.dart';
import 'HistoryScreen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProTalk Mode Selection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFD9CCB7),
      ),
      home: const ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  int _currentIndex = 0;
  
  final List<Widget> _pages = [
    const Knowledgebase(), // Полноценный экран из knowledgebase.dart
    const ModeContentScreen(),
    const Placeholder(),
    const HistoryScreen(),
    const UserScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text('Тест', style: TextStyle(fontSize: 24)),
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
        backgroundColor: Colors.black45,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Б',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Т',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'С',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'И',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'П',
          ),
        ],
      ),
    );
  }
}

class ModeContentScreen extends StatefulWidget {
  const ModeContentScreen({super.key});

  @override
  State<ModeContentScreen> createState() => _ModeContentScreenState();
}

class _ModeContentScreenState extends State<ModeContentScreen> {
  bool _softSelected = false;
  bool _hardSelected = false;
  String? _selectedMode;
  int? _selectedTheme;

  final List<String> _softThemes = ['Тема 1', 'Тема 2', 'Тема 3'];
  final List<String> _hardThemes = ['Тема A', 'Тема B', 'Тема C'];

  void _selectSoft() {
    setState(() {
      _softSelected = true;
      _hardSelected = false;
      _selectedMode = 'Soft';
      _selectedTheme = null;
    });
  }

  void _selectHard() {
    setState(() {
      _softSelected = false;
      _hardSelected = true;
      _selectedMode = 'Hard';
      _selectedTheme = null;
    });
  }

  void _selectTheme(int themeIndex) {
    setState(() {
      _selectedTheme = themeIndex;
    });
  }

  void _navigateToQuestionScreen(int questionNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionScreen(
          mode: _selectedMode!,
          theme: _softSelected 
              ? _softThemes[_selectedTheme!] 
              : _hardThemes[_selectedTheme!],
          questionNumber: questionNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: ElevatedButton(
            onPressed: _selectSoft,
            style: ElevatedButton.styleFrom(
              backgroundColor: _softSelected ? Colors.blueAccent : Colors.blueGrey[800],
              minimumSize: const Size(double.infinity, 70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'soft',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
          child: ElevatedButton(
            onPressed: _selectHard,
            style: ElevatedButton.styleFrom(
              backgroundColor: _hardSelected ? Colors.redAccent : Colors.red[800],
              minimumSize: const Size(double.infinity, 70),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'hard',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        if (_softSelected || _hardSelected)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: (_softSelected ? _softThemes : _hardThemes).asMap().entries.map((entry) {
                  final index = entry.key;
                  final theme = entry.value;
                  return Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
                        child: ElevatedButton(
                          onPressed: () => _selectTheme(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedTheme == index 
                                ? Colors.grey[600] 
                                : Colors.grey[800],
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            theme,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      if (_selectedTheme == index)
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToQuestionScreen(1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Вопрос 1',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToQuestionScreen(2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Вопрос 2',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToQuestionScreen(3),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Вопрос 3',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}

class QuestionScreen extends StatelessWidget {
  final String mode;
  final String theme;
  final int questionNumber;

  const QuestionScreen({
    super.key,
    required this.mode,
    required this.theme,
    required this.questionNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: Text('$mode - $theme - Вопрос $questionNumber'),
        backgroundColor: Colors.black45,
      ),
      body: Center(
        child: Text(
          'Это экран вопроса $questionNumber в теме "$theme" режима $mode',
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}