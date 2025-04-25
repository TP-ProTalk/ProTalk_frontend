import 'package:flutter/material.dart';

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
        scaffoldBackgroundColor: const Color(0xFF2F2F2F),
      ),
      home: const ModeSelectionScreen(),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen ({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool _softSelected = false;
  bool _hardSelected = false;

  void _selectSoft() {
    setState(() {
      _softSelected = true;
      _hardSelected = false;
    });
  }

  void _selectHard() {
    setState(() {
      _softSelected = false;
      _hardSelected = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Выберите режим'),
        backgroundColor: Colors.black45,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка Soft (основная или уменьшенная)
              ElevatedButton(
                onPressed: _selectSoft,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _softSelected ? Colors.blueAccent : Colors.blueGrey[800],
                  padding: EdgeInsets.symmetric(
                    horizontal: _softSelected ? 100 : 50,
                    vertical: _softSelected ? 25 : 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Soft',
                  style: TextStyle(
                    fontSize: _softSelected ? 24 : 18,
                    color: Colors.white,
                  ),
                ), 
              ),
              

              const SizedBox(height: 20),

              // Анимация кнопки Hard
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: _softSelected ? EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2)
                : EdgeInsets.zero,
                child: Transform.scale(
                  scale: _softSelected ? 0.8 : 1.0,
                  child: ElevatedButton(
                    onPressed: _selectHard,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _hardSelected ? Colors.redAccent : Colors.red[800],
                      padding: EdgeInsets.symmetric(
                        horizontal: _hardSelected ? 100 : 50,
                        vertical: _hardSelected ? 25 : 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ), 
                    ),
                    child: Text(
                      'Hard',
                      style: TextStyle(
                        fontSize: _hardSelected ? 24 : 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              // Анимация кнопки Soft
              if (_hardSelected)
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.2),
                child: Transform.scale(
                  scale: 0.8,
                  child: ElevatedButton(
                    onPressed: _selectSoft,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ), 
                    ),
                    child: const Text(
                      'Soft',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      );
  }
}