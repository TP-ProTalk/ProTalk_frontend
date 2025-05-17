import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';
import 'package:protalk_frontend/frames/login_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  bool _isLoading = true;
  String? _error;
  bool _isEditing = false;
  File? _avatarFile;
  Map<String, dynamic>? _userProfile;
  final ApiService _apiService = ApiService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _patronymicController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _vacancyController = TextEditingController();
  final TextEditingController _gradeController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();
  final TextEditingController _educationController = TextEditingController();
  final TextEditingController _skillsController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  final List<String> _grades = [
    'Intern',
    'Junior',
    'Middle',
    'Senior',
  ];

  final Map<String, List<String>> _itVacanciesByCategory = {
    'Разработка': [
      'Frontend Developer',
      'Backend Developer',
      'Full Stack Developer',
      'Mobile Developer',
      'Game Developer',
      'Unity Developer',
      'Embedded Developer',
      'Blockchain Developer',
      'AR/VR Developer',
    ],
    'DevOps и Системы': [
      'DevOps Engineer',
      'System Administrator',
      'Cloud Engineer',
      'Network Engineer',
      'Database Administrator',
    ],
    'Тестирование': [
      'QA Engineer',
      'QA Automation Engineer',
      'Performance Engineer',
    ],
    'Данные и AI': [
      'Data Scientist',
      'Data Engineer',
      'Machine Learning Engineer',
      'AI Engineer',
    ],
    'Безопасность': [
      'Security Engineer',
    ],
    'Управление': [
      'Technical Lead',
      'Team Lead',
      'Project Manager',
      'Product Manager',
    ],
    'Другие роли': [
      'Business Analyst',
      'UI/UX Designer',
      'Technical Writer',
      'Support Engineer',
    ],
  };

  String _searchQuery = '';
  List<String> get _filteredVacancies {
    final allVacancies =
        _itVacanciesByCategory.values.expand((x) => x).toList();
    if (_searchQuery.isEmpty) return allVacancies;
    return allVacancies
        .where((vacancy) =>
            vacancy.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAvatar();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _vacancyController.dispose();
    _gradeController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final profile = await _apiService.getUserProfile(token);

      if (mounted) {
        setState(() {
          _userProfile = {
            'id': profile['id']?.toString() ?? '',
            'email': profile['email'] ?? '',
            'name': profile['name'] ?? 'Не указано',
            'surname': profile['surname'] ?? 'Не указано',
            'patronymic': profile['patronymic'] ?? 'Не указано',
            'phone': profile['phone'] ?? 'Не указано',
            'birth_date':
                profile['birth_date'] ?? DateTime.now().toIso8601String(),
            'vacancy': profile['vacancy'] ?? 'Не указано',
            'grade': profile['grade'] ?? 'Не указано',
            'experience': profile['experience']?.toString() ?? '0',
            'education': profile['education'] ?? 'Не указано',
            'skills': profile['skills'] ?? 'Не указано',
            'about': profile['about'] ?? 'Не указано',
          };

          _nameController.text = _userProfile!['name'] as String;
          _surnameController.text = _userProfile!['surname'] as String;
          _patronymicController.text = _userProfile!['patronymic'] as String;
          _emailController.text = _userProfile!['email'] as String;
          _phoneController.text = _userProfile!['phone'] as String;
          _birthDateController.text = _userProfile!['birth_date'] as String;
          _vacancyController.text = _userProfile!['vacancy'] as String;
          _gradeController.text = _userProfile!['grade'] as String;
          _experienceController.text = _userProfile!['experience'] as String;
          _educationController.text = _userProfile!['education'] as String;
          _skillsController.text = _userProfile!['skills'] as String;
          _aboutController.text = _userProfile!['about'] as String;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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

  Future<void> _saveProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final profileData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'patronymic': _patronymicController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'birth_date': _birthDateController.text,
        'vacancy': _vacancyController.text,
        'grade': _gradeController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'education': _educationController.text,
        'skills': _skillsController.text,
        'about': _aboutController.text,
      };

      await _apiService.updateUserProfile(token, profileData);

      if (mounted) {
        setState(() {
          _userProfile = {
            'id': _userProfile?['id']?.toString() ?? '',
            ...profileData,
          };
          _isLoading = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Профиль успешно обновлен'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка при сохранении профиля: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтверждение выхода'),
        content: const Text('Вы действительно хотите выйти из аккаунта?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Выйти', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.clearToken();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Профиль',
          style: TextStyle(fontFamily: 'Cuyabra'),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(80, 0, 0, 0),
        elevation: 1,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: _isEditing
                ? _saveProfile
                : () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child:
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                )
              : SingleChildScrollView(
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
                            _buildEditableField(
                              Icons.person,
                              'Имя',
                              _nameController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.person,
                              'Фамилия',
                              _surnameController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.person,
                              'Отчество',
                              _patronymicController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.email,
                              'Почта',
                              _emailController,
                              enabled: false,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.phone,
                              'Телефон',
                              _phoneController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.calendar_today,
                              'Дата рождения',
                              _birthDateController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.work,
                              'Вакансия',
                              _vacancyController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.school,
                              'Грейд',
                              _gradeController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.timeline,
                              'Опыт работы',
                              _experienceController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.school,
                              'Образование',
                              _educationController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.build,
                              'Навыки',
                              _skillsController,
                            ),
                            const SizedBox(height: 10),
                            _buildEditableField(
                              Icons.info,
                              'О себе',
                              _aboutController,
                              maxLines: 3,
                            ),
                            const SizedBox(height: 30),
                            _buildLogoutButton(),
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
      child: _avatarFile == null
          ? const Icon(Icons.person, size: 50, color: Colors.white)
          : null,
    );
  }

  Widget _buildEditableField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    if (label == 'Вакансия' && _isEditing) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Поиск вакансии...',
                  prefixIcon: const Icon(Icons.search, color: Colors.black54),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Divider(height: 1),
            SizedBox(
              height: 300,
              child: _searchQuery.isEmpty
                  ? ListView.builder(
                      itemCount: _itVacanciesByCategory.length,
                      itemBuilder: (context, index) {
                        final category =
                            _itVacanciesByCategory.keys.elementAt(index);
                        final vacancies = _itVacanciesByCategory[category]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                              child: Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            ...vacancies.map((vacancy) => ListTile(
                                  title: Text(vacancy),
                                  selected: controller.text == vacancy,
                                  onTap: () {
                                    controller.text = vacancy;
                                    setState(() {});
                                  },
                                )),
                            if (index < _itVacanciesByCategory.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: _filteredVacancies.length,
                      itemBuilder: (context, index) {
                        final vacancy = _filteredVacancies[index];
                        return ListTile(
                          title: Text(vacancy),
                          selected: controller.text == vacancy,
                          onTap: () {
                            controller.text = vacancy;
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      );
    }

    if (label == 'Грейд' && _isEditing) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: DropdownButtonFormField<String>(
            value: controller.text.isEmpty ? null : controller.text,
            decoration: InputDecoration(
              border: InputBorder.none,
              labelText: label,
              prefixIcon: Icon(icon, color: Colors.black54),
            ),
            items: _grades.map((String grade) {
              return DropdownMenuItem<String>(
                value: grade,
                child: Text(grade),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                controller.text = newValue;
              }
            },
          ),
        ),
      );
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Colors.black54),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: _isEditing && enabled
            ? TextFormField(
                controller: controller,
                decoration: const InputDecoration(border: InputBorder.none),
                maxLines: maxLines,
              )
            : Text(controller.text.isEmpty ? 'Не указано' : controller.text),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _logout,
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
}
