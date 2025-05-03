import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    setState(() => _isLoading = true);
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'phone_number': _phoneController.text,
        'age': int.tryParse(_ageController.text) ?? 0,
        'sex': _sexController.text,
        'grade': _gradeController.text,
        'password': _passwordController.text,
      }),
    );
    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context); // Вернуться на экран логина
    } else {
      _showErrorDialog('Ошибка при регистрации. Проверьте данные.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Ошибка'),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ОК'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Телефон'),
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Возраст'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _sexController,
              decoration: const InputDecoration(labelText: 'Пол'),
            ),
            TextField(
              controller: _gradeController,
              decoration: const InputDecoration(labelText: 'Грейд'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _register,
              child:
                  _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Зарегистрироваться'),
            ),
          ],
        ),
      ),
    );
  }
}
