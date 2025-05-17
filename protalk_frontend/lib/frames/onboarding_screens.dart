import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' show min;
import '../services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';
import 'package:protalk_frontend/frames/bottom_nav_wrapper.dart';
import 'package:protalk_frontend/config/app_config.dart';

class OnboardingScreens extends StatefulWidget {
  final String email;
  final String password;

  const OnboardingScreens({
    Key? key,
    required this.email,
    required this.password,
  }) : super(key: key);

  @override
  State<OnboardingScreens> createState() => _OnboardingScreensState();
}

class _OnboardingScreensState extends State<OnboardingScreens> {
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
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadVacancies();
  }

  Future<void> _loadVacancies() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (AppConfig.offlineMode) {
        // Используем тестовые данные в офлайн режиме
        setState(() {
          _vacancies = [
            {'id': '1', 'title': 'Python Developer'},
            {'id': '2', 'title': 'Java Developer'},
            {'id': '3', 'title': 'Frontend Developer'},
            {'id': '4', 'title': 'Backend Developer'},
            {'id': '5', 'title': 'DevOps Engineer'},
          ];
          _isLoading = false;
        });
        return;
      }

      final vacancies = await _apiService.getVacancies('');

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
          if (e.toString().contains('SocketException') ||
              e.toString().contains('NetworkError') ||
              e.toString().contains('timeout')) {
            _errorMessage =
                'Нет подключения к интернету. Проверьте соединение и попробуйте снова.';
          } else {
            _errorMessage = 'Ошибка загрузки списка вакансий: ${e.toString()}';
          }
        });
      }
    }
  }

  // Маска для даты рождения
  String _formatDate(String input) {
    if (input.isEmpty) return input;

    // Удаляем все нецифровые символы
    String digits = input.replaceAll(RegExp(r'[^\d]'), '');

    // Форматируем дату
    if (digits.length <= 2) {
      return digits;
    } else if (digits.length <= 4) {
      return '${digits.substring(0, 2)}.${digits.substring(2)}';
    } else {
      return '${digits.substring(0, 2)}.${digits.substring(2, 4)}.${digits.substring(4, min(8, digits.length))}';
    }
  }

  // Получение новой позиции курсора
  int _getNewCursorPosition(
      String oldText, String newText, int oldCursorPosition) {
    if (oldText.isEmpty) return newText.length;

    // Если добавляем точку
    if (newText.length > oldText.length &&
        (newText.length == 3 || newText.length == 6)) {
      return oldCursorPosition + 1;
    }

    // Если удаляем точку
    if (newText.length < oldText.length &&
        (oldText.length == 3 || oldText.length == 6)) {
      return oldCursorPosition - 1;
    }

    return oldCursorPosition;
  }

  // Валидация даты рождения
  String? _validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, введите дату рождения';
    }

    // Проверяем формат даты (ДД.ММ.ГГГГ)
    final dateRegex = RegExp(r'^\d{2}\.\d{2}\.\d{4}$');
    if (!dateRegex.hasMatch(value)) {
      return 'Введите дату в формате ДД.ММ.ГГГГ';
    }

    try {
      final parts = value.split('.');
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);

      // Проверяем корректность дня
      if (day < 1 || day > 31) {
        return 'День должен быть от 1 до 31';
      }

      // Проверяем корректность месяца
      if (month < 1 || month > 12) {
        return 'Месяц должен быть от 1 до 12';
      }

      // Проверяем корректность года
      final currentYear = DateTime.now().year;
      if (year < 1900 || year > currentYear) {
        return 'Год должен быть от 1900 до $currentYear';
      }

      // Проверяем существование даты (например, 31.02.2024 не существует)
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Такой даты не существует';
      }

      // Проверяем, что дата не в будущем
      if (date.isAfter(DateTime.now())) {
        return 'Дата не может быть в будущем';
      }

      // Проверяем минимальный возраст (например, 14 лет)
      final minAge = 14;
      final minDate = DateTime(currentYear - minAge, month, day);
      if (date.isAfter(minDate)) {
        return 'Возраст должен быть не менее $minAge лет';
      }

      return null;
    } catch (e) {
      return 'Неверный формат даты';
    }
  }

  // Валидация вакансий
  String? _validateVacancies() {
    // Проверяем только если мы на шаге вакансий или на последнем шаге
    if (_currentStep >= 1) {
      // Проверяем, что выбрана хотя бы одна вакансия
      if (_selectedMainVacancy == null &&
          _selectedSecondaryVacancy1 == null &&
          _selectedSecondaryVacancy2 == null) {
        return 'Пожалуйста, выберите хотя бы одну вакансию';
      }

      // Проверяем, что вторая вакансия не совпадает с первой
      if (_selectedSecondaryVacancy1 != null &&
          _selectedSecondaryVacancy1 == _selectedMainVacancy) {
        return 'Вторая вакансия не может совпадать с основной';
      }

      // Проверяем, что третья вакансия не совпадает с первой или второй
      if (_selectedSecondaryVacancy2 != null &&
          (_selectedSecondaryVacancy2 == _selectedMainVacancy ||
              _selectedSecondaryVacancy2 == _selectedSecondaryVacancy1)) {
        return 'Третья вакансия не может совпадать с другими выбранными вакансиями';
      }
    }
    return null;
  }

  // Получение списка доступных вакансий для выпадающего списка
  List<DropdownMenuItem<String>> _getAvailableVacancies(
      String? excludeVacancy1, String? excludeVacancy2) {
    return _vacancies
        .where((vacancy) =>
            vacancy['id'].toString() != excludeVacancy1 &&
            vacancy['id'].toString() != excludeVacancy2)
        .map((vacancy) {
      return DropdownMenuItem<String>(
        value: vacancy['id'].toString(),
        child: Text(vacancy['title'] ?? ''),
      );
    }).toList();
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Имя *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, введите имя';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _surnameController,
          decoration: const InputDecoration(
            labelText: 'Фамилия *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, введите фамилию';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _birthDateController,
          decoration: const InputDecoration(
            labelText: 'Дата рождения *',
            border: OutlineInputBorder(),
            hintText: 'ДД.ММ.ГГГГ',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            TextInputFormatter.withFunction((oldValue, newValue) {
              final formattedText = _formatDate(newValue.text);
              final newCursorPosition = _getNewCursorPosition(
                oldValue.text,
                formattedText,
                newValue.selection.baseOffset,
              );

              return TextEditingValue(
                text: formattedText,
                selection: TextSelection.collapsed(offset: newCursorPosition),
              );
            }),
            LengthLimitingTextInputFormatter(10),
          ],
          validator: _validateDate,
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _patronymicController,
          decoration: const InputDecoration(
            labelText: 'Отчество',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Телефон',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildVacancyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<String>(
          value: _selectedMainVacancy,
          decoration: const InputDecoration(
            labelText: 'Основная вакансия',
            border: OutlineInputBorder(),
          ),
          items: _getAvailableVacancies(
              _selectedSecondaryVacancy1, _selectedSecondaryVacancy2),
          onChanged: (value) {
            setState(() {
              _selectedMainVacancy = value;
              if (_selectedSecondaryVacancy1 == value) {
                _selectedSecondaryVacancy1 = null;
              }
              if (_selectedSecondaryVacancy2 == value) {
                _selectedSecondaryVacancy2 = null;
              }
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedSecondaryVacancy1,
          decoration: const InputDecoration(
            labelText: 'Второстепенная вакансия 1',
            border: OutlineInputBorder(),
          ),
          items: _getAvailableVacancies(
              _selectedMainVacancy, _selectedSecondaryVacancy2),
          onChanged: (value) {
            setState(() {
              _selectedSecondaryVacancy1 = value;
              if (_selectedMainVacancy == value) {
                _selectedMainVacancy = null;
              }
              if (_selectedSecondaryVacancy2 == value) {
                _selectedSecondaryVacancy2 = null;
              }
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedSecondaryVacancy2,
          decoration: const InputDecoration(
            labelText: 'Второстепенная вакансия 2',
            border: OutlineInputBorder(),
          ),
          items: _getAvailableVacancies(
              _selectedMainVacancy, _selectedSecondaryVacancy1),
          onChanged: (value) {
            setState(() {
              _selectedSecondaryVacancy2 = value;
              if (_selectedMainVacancy == value) {
                _selectedMainVacancy = null;
              }
              if (_selectedSecondaryVacancy1 == value) {
                _selectedSecondaryVacancy1 = null;
              }
              _errorMessage = null;
            });
          },
        ),
        Builder(
          builder: (context) {
            if (_currentStep >= 1) {
              final error = _validateVacancies();
              if (error != null &&
                  error != 'Пожалуйста, выберите хотя бы одну вакансию') {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                );
              }
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(height: 16.0),
        DropdownButtonFormField<String>(
          value: _selectedGrade,
          decoration: const InputDecoration(
            labelText: 'Грейд *',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, выберите грейд';
            }
            return null;
          },
          items: const [
            DropdownMenuItem(value: 'Junior', child: Text('Junior')),
            DropdownMenuItem(value: 'Middle', child: Text('Middle')),
            DropdownMenuItem(value: 'Senior', child: Text('Senior')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedGrade = value;
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _experienceController,
          decoration: const InputDecoration(
            labelText: 'Опыт работы (лет) *',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Пожалуйста, укажите опыт работы';
            }
            final experience = int.tryParse(value);
            if (experience == null || experience < 0) {
              return 'Пожалуйста, введите корректное значение';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _educationController,
          decoration: const InputDecoration(
            labelText: 'Образование',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _skillsController,
          decoration: const InputDecoration(
            labelText: 'Навыки',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
        const SizedBox(height: 16.0),
        TextFormField(
          controller: _aboutController,
          decoration: const InputDecoration(
            labelText: 'О себе',
            border: OutlineInputBorder(),
          ),
          maxLines: 4,
          onChanged: (value) {
            setState(() {
              _errorMessage = null;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD9CCB7),
        elevation: 0,
        title: const Text('Заполните профиль'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 16.0),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline,
                                  color: Colors.red.shade900),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: TextStyle(color: Colors.red.shade900),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Stepper(
                        currentStep: _currentStep,
                        onStepContinue: () {
                          if (_currentStep < 2) {
                            // Проверяем валидацию перед переходом к следующему шагу
                            if (_currentStep == 1) {
                              final vacancyError = _validateVacancies();
                              if (vacancyError != null) {
                                setState(() {
                                  _errorMessage = vacancyError;
                                });
                                return;
                              }
                            }
                            setState(() {
                              _currentStep += 1;
                              _errorMessage = null;
                            });
                          } else {
                            _registerAndSaveProfile();
                          }
                        },
                        onStepCancel: () {
                          if (_currentStep > 0) {
                            setState(() {
                              _currentStep -= 1;
                              _errorMessage = null;
                            });
                          }
                        },
                        controlsBuilder: (context, details) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: Row(
                              children: [
                                if (_currentStep > 0)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: details.onStepCancel,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[300],
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                      ),
                                      child: const Text('Назад'),
                                    ),
                                  ),
                                if (_currentStep > 0)
                                  const SizedBox(width: 16.0),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : details.onStepContinue,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(
                                          255, 127, 113, 179),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16.0),
                                    ),
                                    child: _isLoading
                                        ? const CircularProgressIndicator()
                                        : Text(_currentStep == 2
                                            ? 'Завершить'
                                            : 'Далее'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        steps: [
                          Step(
                            title: const Text('Личные данные'),
                            content: _buildPersonalInfoStep(),
                            isActive: _currentStep >= 0,
                          ),
                          Step(
                            title: const Text('Вакансия и опыт'),
                            content: _buildVacancyStep(),
                            isActive: _currentStep >= 1,
                          ),
                          Step(
                            title: const Text('Дополнительная информация'),
                            content: _buildAdditionalInfoStep(),
                            isActive: _currentStep >= 2,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Future<void> _registerAndSaveProfile() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final vacancyError = _validateVacancies();
    if (vacancyError != null) {
      setState(() {
        _errorMessage = vacancyError;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      if (AppConfig.offlineMode) {
        // В офлайн режиме просто переходим на главный экран
        await Future.delayed(const Duration(seconds: 1)); // Имитация задержки
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavWrapper()),
          );
        }
        return;
      }

      try {
        final token = await _apiService.register(
          widget.email,
          widget.password,
        );

        if (token == null) {
          throw Exception('Ошибка регистрации');
        }

        await AuthService.saveToken(token, '');

        final profileData = {
          'name': _nameController.text,
          'surname': _surnameController.text,
          'patronymic': _patronymicController.text,
          'email': widget.email,
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

        await _apiService.updateUserProfile(token, profileData);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const BottomNavWrapper()),
          );
        }
      } catch (e) {
        if (e.toString().contains('SocketException') ||
            e.toString().contains('NetworkError') ||
            e.toString().contains('timeout')) {
          throw Exception(
              'Нет подключения к интернету. Проверьте соединение и попробуйте снова.');
        }
        rethrow;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
