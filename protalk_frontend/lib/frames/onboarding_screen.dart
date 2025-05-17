import 'package:flutter/material.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  bool _isLoading = false;
  String? _error;

  // Контроллеры для полей формы
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _mainVacancyController = TextEditingController();
  final _secondaryVacancy1Controller = TextEditingController();
  final _secondaryVacancy2Controller = TextEditingController();
  final _gradeController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _aboutController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _mainVacancyController.dispose();
    _secondaryVacancy1Controller.dispose();
    _secondaryVacancy2Controller.dispose();
    _gradeController.dispose();
    _experienceController.dispose();
    _educationController.dispose();
    _skillsController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final userData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'patronymic': _patronymicController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'birth_date': _birthDateController.text,
        'main_vacancy': _mainVacancyController.text,
        'secondary_vacancy1': _secondaryVacancy1Controller.text,
        'secondary_vacancy2': _secondaryVacancy2Controller.text,
        'grade': _gradeController.text,
        'experience': int.tryParse(_experienceController.text) ?? 0,
        'education': _educationController.text,
        'skills': _skillsController.text,
        'about': _aboutController.text,
      };

      await _apiService.updateUserProfile(token, userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Профиль успешно обновлен')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        title: const Text(
          'Обновление профиля',
          style: TextStyle(
            fontFamily: 'Cuyabra',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 127, 113, 179),
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    _buildSection(
                      'Личная информация',
                      [
                        _buildTextField(
                          'Имя',
                          _nameController,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Введите имя' : null,
                        ),
                        _buildTextField(
                          'Фамилия',
                          _surnameController,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Введите фамилию' : null,
                        ),
                        _buildTextField('Отчество', _patronymicController),
                        _buildTextField(
                          'Email',
                          _emailController,
                          validator: (value) =>
                              value?.isEmpty ?? true ? 'Введите email' : null,
                        ),
                        _buildTextField('Телефон', _phoneController),
                        _buildTextField('Дата рождения', _birthDateController),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Профессиональная информация',
                      [
                        _buildTextField(
                          'Основная вакансия',
                          _mainVacancyController,
                          validator: (value) => value?.isEmpty ?? true
                              ? 'Введите вакансию'
                              : null,
                        ),
                        _buildTextField('Дополнительная вакансия 1',
                            _secondaryVacancy1Controller),
                        _buildTextField('Дополнительная вакансия 2',
                            _secondaryVacancy2Controller),
                        _buildTextField('Уровень', _gradeController),
                        _buildTextField('Опыт работы', _experienceController),
                        _buildTextField('Образование', _educationController),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Дополнительная информация',
                      [
                        _buildTextField('Навыки', _skillsController),
                        _buildTextField(
                          'О себе',
                          _aboutController,
                          maxLines: 3,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 127, 113, 179),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Сохранить',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        validator: validator,
        maxLines: maxLines,
      ),
    );
  }
}
