import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';
import 'package:protalk_frontend/frames/login_screen.dart';
import 'package:protalk_frontend/frames/onboarding_screens.dart';
import 'package:protalk_frontend/styles/theme.dart';

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
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Профиль',
          style: TextStyle(fontFamily: 'Cuyabra'),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
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
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _isEditing ? _pickAvatar : null,
                        child: _buildAvatar(),
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        '${_userProfile!['name']} ${_userProfile!['surname']}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (_userProfile!['patronymic'] != null)
                        Text(
                          _userProfile!['patronymic'],
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                      const SizedBox(height: 32.0),
                      _buildInfoCard(
                        'Основная вакансия',
                        _userProfile!['vacancy'] ?? 'Не указана',
                      ),
                      const SizedBox(height: 16.0),
                      _buildInfoCard(
                        'Грейд',
                        _userProfile!['grade'] ?? 'Не указан',
                      ),
                      const SizedBox(height: 16.0),
                      _buildInfoCard(
                        'Опыт работы',
                        '${_userProfile!['experience'] ?? 0} лет',
                      ),
                      const SizedBox(height: 16.0),
                      _buildInfoCard(
                        'Телефон',
                        _userProfile!['phone'] ?? 'Не указан',
                      ),
                      const SizedBox(height: 16.0),
                      _buildInfoCard(
                        'Email',
                        _userProfile!['email'] ?? 'Не указан',
                      ),
                      const SizedBox(height: 32.0),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 20),
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OnboardingScreens(
                                  email: _userProfile!['email'] ?? '',
                                  password: '',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.person_add),
                          label: const Text('Заполнить профиль'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 127, 113, 179),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 50.0,
      backgroundColor: AppTheme.primaryColor,
      backgroundImage: _avatarFile != null ? FileImage(_avatarFile!) : null,
      child: _avatarFile == null
          ? const Icon(Icons.person, size: 50, color: Colors.white)
          : null,
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
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
