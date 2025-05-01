import 'package:flutter/material.dart';

void main() {
  runApp(const Knowledgebase());
}

class Knowledgebase extends StatelessWidget {
  const Knowledgebase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'База знаний',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFD9CCB7),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('База знаний', style: TextStyle(fontSize: 24)),
          backgroundColor: Colors.black45,
          centerTitle: true,
        ),
        body: const ModeSelectionScreen(),
      ),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
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

  void _navigateToArticleScreen(int articleNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          mode: _selectedMode!,
          theme: _softSelected 
              ? _softThemes[_selectedTheme!] 
              : _hardThemes[_selectedTheme!],
          articleNumber: articleNumber,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Кнопка Soft
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

        // Кнопка Hard
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

        // Темы (появляются после выбора режима)
        if (_softSelected || _hardSelected)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: (_softSelected ? _softThemes : _hardThemes).asMap().entries.map((entry) {
                  final index = entry.key;
                  final theme = entry.value;
                  return Column(
                    children: [
                      // Кнопка темы
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

                      // Статьи для выбранной темы
                      if (_selectedTheme == index)
                        Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToArticleScreen(1),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Статья 1',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToArticleScreen(2),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Статья 2',
                                  style: TextStyle(fontSize: 16, color: Colors.white),
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 70, vertical: 5),
                              child: ElevatedButton(
                                onPressed: () => _navigateToArticleScreen(3),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey[700],
                                  minimumSize: const Size(double.infinity, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Статья 3',
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

class ArticleScreen extends StatelessWidget {
  final String mode;
  final String theme;
  final int articleNumber;

  const ArticleScreen({
    super.key,
    required this.mode,
    required this.theme,
    required this.articleNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$mode - $theme - Статья $articleNumber'),
        backgroundColor: Colors.black45,
      ),
      body: Center(
        child: Text(
          'Это экран статьи $articleNumber в теме "$theme" режима $mode',
          style: const TextStyle(color: Colors.white, fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}