import 'package:flutter/material.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';
import 'package:protalk_frontend/frames/login_screen.dart';
import 'package:protalk_frontend/frames/mode_selection_screen.dart';
import 'package:protalk_frontend/frames/onboarding_screens.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final _apiService = ApiService();
  String? _error;

  // Функция для удаления пробелов в конце строки
  String _trimTrailingSpaces(String value) {
    return value.trimRight();
  }

  Future<void> _register() async {
    // Скрываем клавиатуру
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      try {
        print('Начало регистрации...');
        // Сначала создаем пользователя с минимальными данными
        final token = await _apiService.register(
          _trimTrailingSpaces(_emailController.text),
          _trimTrailingSpaces(_passwordController.text),
          '+7', // Минимальный номер телефона
          18, // Минимальный возраст
          'male', // Пол по умолчанию
          'Junior', // Грейд по умолчанию
        );

        print('Получен токен: $token');

        if (token == null) {
          throw Exception('Ошибка регистрации: токен не получен');
        }

        if (mounted) {
          print('Переход на экран онбординга...');
          await Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => OnboardingScreens(
                email: _emailController.text,
                password: _passwordController.text,
              ),
            ),
          );
        }
      } catch (e) {
        print('Ошибка при регистрации: $e');
        setState(() {
          _error = e.toString();
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _goToLogin() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
    return emailRegExp.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9CCB7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(255, 127, 113, 179),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Регистрация',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 127, 113, 179),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.email),
                    ),
                    onChanged: (value) {
                      _emailController.text = _trimTrailingSpaces(value);
                      _emailController.selection = TextSelection.fromPosition(
                        TextPosition(offset: _emailController.text.length),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите email';
                      } else if (!_isValidEmail(_trimTrailingSpaces(value))) {
                        return 'Некорректный email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Пароль',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock),
                    ),
                    onChanged: (value) {
                      _passwordController.text = _trimTrailingSpaces(value);
                      _passwordController.selection =
                          TextSelection.fromPosition(
                        TextPosition(offset: _passwordController.text.length),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Введите пароль';
                      } else if (_trimTrailingSpaces(value).length < 6) {
                        return 'Пароль должен быть не менее 6 символов';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите пароль',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.lock_outline),
                    ),
                    onChanged: (value) {
                      _confirmPasswordController.text =
                          _trimTrailingSpaces(value);
                      _confirmPasswordController.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                            offset: _confirmPasswordController.text.length),
                      );
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Подтвердите пароль';
                      } else if (_trimTrailingSpaces(value) !=
                          _trimTrailingSpaces(_passwordController.text)) {
                        return 'Пароли не совпадают';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Зарегистрироваться',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _goToLogin,
                    child: const Text.rich(
                      TextSpan(
                        text: 'Уже есть аккаунт? ',
                        style: TextStyle(
                          color: Color.fromARGB(255, 127, 113, 179),
                        ),
                        children: [
                          TextSpan(
                            text: 'Войти',
                            style: TextStyle(
                              color: Color.fromARGB(255, 127, 113, 179),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
