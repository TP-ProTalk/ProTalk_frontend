import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protalk_frontend/frames/splash_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isEditing = false;
  File? _avatarFile;

  final TextEditingController _nameController = TextEditingController(
    text: 'Иванов Иван Иванович',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'ivanov@example.com',
  );
  final TextEditingController _gradeController = TextEditingController(
    text: 'Middle',
  );
  final TextEditingController _positionController = TextEditingController(
    text: 'Flutter разработчик',
  );

  @override
  void initState() {
    super.initState();
    _loadAvatar();
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
              setState(() {
                _isEditing = !_isEditing;
              });
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
                  _buildEditableField(Icons.person, 'ФИО', _nameController),
                  const SizedBox(height: 10),
                  _buildEditableField(Icons.email, 'Почта', _emailController),
                  const SizedBox(height: 10),
                  _buildEditableField(Icons.school, 'Грейд', _gradeController),
                  const SizedBox(height: 10),
                  _buildEditableField(
                    Icons.work,
                    'Позиция',
                    _positionController,
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
    TextEditingController controller,
  ) {
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
}
