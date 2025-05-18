import 'package:flutter/material.dart';
import 'package:protalk_frontend/frames/KnowledgeBase.dart';
import 'package:protalk_frontend/frames/test_mode_selection.dart';
import 'package:protalk_frontend/frames/interview_screen.dart';
import 'package:protalk_frontend/frames/onboarding_screens.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text(
          'Главное меню',
          style: TextStyle(
            fontFamily: 'Cuyabra',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 127, 113, 179),
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton(
              context,
              'Собеседование',
              Icons.people,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const InterviewScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'База знаний',
              Icons.menu_book,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ModeSelectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildMenuButton(
              context,
              'Тесты',
              Icons.quiz,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TestModeSelectionScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Профиль'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreens(
                      email: '',
                      password: '',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 70,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 127, 113, 179),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          shadowColor: Colors.black45,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontFamily: 'Cuyabra',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
