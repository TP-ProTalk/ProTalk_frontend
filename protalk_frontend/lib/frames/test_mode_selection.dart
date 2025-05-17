import 'package:flutter/material.dart';
import 'package:protalk_frontend/frames/test_screen.dart';

class TestModeSelectionScreen extends StatefulWidget {
  const TestModeSelectionScreen({super.key});

  @override
  State<TestModeSelectionScreen> createState() =>
      _TestModeSelectionScreenState();
}

class _TestModeSelectionScreenState extends State<TestModeSelectionScreen> {
  bool _softSelected = false;
  bool _hardSelected = false;
  String? _selectedMode;
  int? _selectedTheme;

  final List<String> _softThemes = ['Тема 1', 'Тема 2', 'Тема 3'];
  final List<String> _hardThemes = ['Тема A', 'Тема B', 'Тема C'];

  static const Color accentColor = Color.fromARGB(255, 127, 113, 179);
  static const Color accentLightColor = Color.fromARGB(255, 157, 144, 209);
  static const Color neutralColor = Color.fromARGB(255, 50, 40, 70);

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

  void _navigateToTestScreen(int testNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestScreen(
          mode: _selectedMode!,
          theme: _softSelected
              ? _softThemes[_selectedTheme!]
              : _hardThemes[_selectedTheme!],
          testNumber: testNumber.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text(
          'Тесты',
          style: TextStyle(
            fontFamily: 'Cuyabra',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 127, 113, 179),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка Soft
            ElevatedButton(
              onPressed: _selectSoft,
              style: ElevatedButton.styleFrom(
                backgroundColor: _softSelected ? accentLightColor : accentColor,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Soft Skills',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),

            // Кнопка Hard
            ElevatedButton(
              onPressed: _selectHard,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hardSelected ? accentLightColor : accentColor,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Hard Skills',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            if (_softSelected || _hardSelected)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: (_softSelected ? _softThemes : _hardThemes)
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final theme = entry.value;
                      final isSelected = _selectedTheme == index;

                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 5,
                            ),
                            child: ElevatedButton(
                              onPressed: () => _selectTheme(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? accentLightColor
                                    : neutralColor,
                                minimumSize: const Size(
                                  double.infinity,
                                  50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
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
                          if (isSelected)
                            Column(
                              children: List.generate(3, (i) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 70,
                                    vertical: 5,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => _navigateToTestScreen(
                                      i + 1,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      minimumSize: const Size(
                                        double.infinity,
                                        40,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Тест ${i + 1}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
