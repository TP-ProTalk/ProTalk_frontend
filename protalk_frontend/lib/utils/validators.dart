class Validators {
  static String? validateDate(String? value) {
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

      // Проверяем существование даты
      final date = DateTime(year, month, day);
      if (date.year != year || date.month != month || date.day != day) {
        return 'Такой даты не существует';
      }

      // Проверяем, что дата не в будущем
      if (date.isAfter(DateTime.now())) {
        return 'Дата не может быть в будущем';
      }

      // Проверяем минимальный возраст
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

  static String? validateRequired(String? value) {
    if (value == null || value.isEmpty) {
      return 'Это поле обязательно для заполнения';
    }
    return null;
  }

  static String? validateExperience(String? value) {
    if (value == null || value.isEmpty) {
      return 'Пожалуйста, укажите опыт работы';
    }
    final experience = int.tryParse(value);
    if (experience == null || experience < 0) {
      return 'Пожалуйста, введите корректное значение';
    }
    return null;
  }
}
