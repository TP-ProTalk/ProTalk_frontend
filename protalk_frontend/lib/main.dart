import 'package:flutter/material.dart';
import 'package:protalk_frontend/frames/splash_screen.dart';
import 'package:protalk_frontend/frames/register_screen.dart';
import 'package:protalk_frontend/frames/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:protalk_frontend/frames/mode_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Получаем доступ к SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Проверяем, есть ли токен
  final String? token = prefs.getString('token');

  runApp(ProTalkApp(isAuthenticated: token != null));
}

class ProTalkApp extends StatelessWidget {
  final bool isAuthenticated;

  const ProTalkApp({Key? key, required this.isAuthenticated}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProTalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: const Color(0xFFD9CCB7),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 127, 113, 179),
          foregroundColor: Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color.fromARGB(255, 127, 113, 179),
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          showUnselectedLabels: true,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Cuyabra'),
          bodyMedium: TextStyle(fontFamily: 'Cuyabra'),
          headlineLarge: TextStyle(fontFamily: 'Cuyabra', fontSize: 32),
          headlineMedium: TextStyle(fontFamily: 'Cuyabra', fontSize: 28),
          headlineSmall: TextStyle(fontFamily: 'Cuyabra', fontSize: 24),
          titleLarge: TextStyle(fontFamily: 'Cuyabra', fontSize: 20),
          titleMedium: TextStyle(fontFamily: 'Cuyabra', fontSize: 18),
        ),
      ),
      home:
          isAuthenticated ? const ModeSelectionScreen() : const SplashScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}
