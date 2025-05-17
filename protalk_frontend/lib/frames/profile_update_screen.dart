import 'package:flutter/material.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';

class ProfileUpdateScreen extends StatefulWidget {
  const ProfileUpdateScreen({super.key});

  @override
  State<ProfileUpdateScreen> createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthDateController = TextEditingController();
  final _experienceController = TextEditingController();
  final _educationController = TextEditingController();
  final _skillsController = TextEditingController();
  final _aboutController = TextEditingController();
  String? _selectedMainVacancy;
  String? _selectedSecondaryVacancy1;
  String? _selectedSecondaryVacancy2;
  String? _selectedGrade;
  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _vacancies = [];

  @override
  void initState() {
    super.initState();
    _loadVacancies();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final profile = await _apiService.getUserProfile(token);

      setState(() {
        _nameController.text = profile['name'] ?? '';
        _surnameController.text = profile['surname'] ?? '';
        _patronymicController.text = profile['patronymic'] ?? '';
        _phoneController.text = profile['phone'] ?? '';
        _birthDateController.text = profile['birth_date'] ?? '';
        _experienceController.text = (profile['experience'] ?? 0).toString();
        _educationController.text = profile['education'] ?? '';
        _skillsController.text = profile['skills'] ?? '';
        _aboutController.text = profile['about'] ?? '';
        _selectedMainVacancy = profile['main_vacancy']?.toString();
        _selectedSecondaryVacancy1 = profile['secondary_vacancy1']?.toString();
        _selectedSecondaryVacancy2 = profile['secondary_vacancy2']?.toString();
        _selectedGrade = profile['grade']?.toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _loadVacancies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final vacancies = await _apiService.getVacancies(token);

      if (mounted) {
        setState(() {
          _vacancies = vacancies;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Ошибка загрузки списка вакансий: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final userData = {
        'name': _nameController.text,
        'surname': _surnameController.text,
        'patronymic': _patronymicController.text,
        'phone': _phoneController.text,
        'birth_date': _birthDateController.text,
        'main_vacancy': _selectedMainVacancy,
        'secondary_vacancy1': _selectedSecondaryVacancy1,
        'secondary_vacancy2': _selectedSecondaryVacancy2,
        'grade': _selectedGrade,
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
        _errorMessage = e.toString();
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
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _errorMessage!,
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
                        _buildTextField('Телефон', _phoneController),
                        _buildTextField('Дата рождения', _birthDateController),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSection(
                      'Профессиональная информация',
                      [
                        _buildVacancyDropdown(
                          'Основная вакансия',
                          _selectedMainVacancy,
                          (value) =>
                              setState(() => _selectedMainVacancy = value),
                          validator: (value) =>
                              value == null ? 'Выберите вакансию' : null,
                        ),
                        _buildVacancyDropdown(
                          'Дополнительная вакансия 1',
                          _selectedSecondaryVacancy1,
                          (value) => setState(
                              () => _selectedSecondaryVacancy1 = value),
                        ),
                        _buildVacancyDropdown(
                          'Дополнительная вакансия 2',
                          _selectedSecondaryVacancy2,
                          (value) => setState(
                              () => _selectedSecondaryVacancy2 = value),
                        ),
                        _buildTextField('Уровень', _selectedGrade),
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
    dynamic controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller is TextEditingController ? controller : null,
        initialValue: controller is String ? controller : null,
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

  Widget _buildVacancyDropdown(
    String label,
    String? value,
    void Function(String?) onChanged, {
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _vacancies.map((vacancy) {
          return DropdownMenuItem<String>(
            value: vacancy['id'].toString(),
            child: Text(vacancy['title'] ?? ''),
          );
        }).toList(),
        onChanged: onChanged,
        validator: validator,
      ),
    );
  }
}
