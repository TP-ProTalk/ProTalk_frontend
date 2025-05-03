import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protalk_frontend/frames/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isEditing = false;
  File? _avatarFile;

  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAvatar();
    _fetchUserData();
  }

  Future<void> _loadAvatar() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/avatar.jpg');
    if (await file.exists()) {
      setState(() {
        _avatarFile = file;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final dir = await getApplicationDocumentsDirectory();
      final saved = await File(picked.path).copy('${dir.path}/avatar.jpg');
      setState(() {
        _avatarFile = saved;
      });
    }
  }

  // Обновление данных пользователя
  Future<void> _updateUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    final body = {
      "phone_number": _phoneController.text,
      "age": int.tryParse(_ageController.text) ?? 0,
      "sex": _sexController.text,
      "grade": _gradeController.text,
      "password": _passwordController.text,
    };

    final response = await http.patch(
      Uri.parse('http://your-api-url.com/users/me'), // Замените на реальный URL
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Данные обновлены')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ошибка при обновлении')));
    }
  }

  // Загрузка данных пользователя
  Future<void> _fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://your-api-url.com/users/me'), // Замените на реальный URL
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        _phoneController.text = data['phone_number'] ?? '';
        _ageController.text = data['age']?.toString() ?? '';
        _sexController.text = data['sex'] ?? '';
        _gradeController.text = data['grade'] ?? '';
      });
    }
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 50,
      backgroundColor: Colors.black45,
      backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
      child:
          _avatarFile == null
              ? const Icon(Icons.person, size: 50, color: Colors.white)
              : null,
    );
  }

  Widget _buildEditableField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool obscureText = false,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle:
            _isEditing
                ? TextFormField(
                  controller: controller,
                  decoration: const InputDecoration(border: InputBorder.none),
                  obscureText: obscureText,
                )
                : Text(controller.text),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _showLogoutDialog(context),
        icon: const Icon(Icons.logout),
        label: const Text('Выйти из аккаунта'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.redAccent,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Подтверждение выхода'),
            content: const Text('Вы действительно хотите выйти из аккаунта?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Вы успешно вышли из аккаунта'),
                    ),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
                },
                child: const Text('Выйти', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Профиль'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(80, 0, 0, 0),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              if (_isEditing) _updateUserData();
              setState(() => _isEditing = !_isEditing);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            GestureDetector(
              onTap: _isEditing ? _pickAvatar : null,
              child: _buildAvatar(),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  _buildEditableField(Icons.phone, 'Телефон', _phoneController),
                  const SizedBox(height: 10),
                  _buildEditableField(Icons.cake, 'Возраст', _ageController),
                  const SizedBox(height: 10),
                  _buildEditableField(Icons.person, 'Пол', _sexController),
                  const SizedBox(height: 10),
                  _buildEditableField(Icons.school, 'Грейд', _gradeController),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    Icons.lock,
                    'Пароль',
                    _passwordController,
                    obscureText: true,
                  ),
                  const SizedBox(height: 30),
                  _buildLogoutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
