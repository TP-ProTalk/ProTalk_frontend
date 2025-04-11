import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProTalk Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String responseMessage = 'Нажми кнопку для запроса';

  Future<void> sendTestRequest() async {
    final url = Uri.parse(
      'http://10.0.2.2:8000/test',
    ); // или 127.0.0.1, если в браузере
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': 'Hello debil'}),
      );
      setState(() {
        responseMessage = 'Ответ от сервера: ${response.body}';
      });
    } catch (e) {
      setState(() {
        responseMessage = 'Ошибка: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ProTalk')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(responseMessage),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendTestRequest,
              child: const Text('Отправить тестовый запрос'),
            ),
          ],
        ),
      ),
    );
  }
}
