class AppConfig {
  // Включить для тестирования UI без подключения к серверу
  static bool offlineMode = true;

  // Тестовые учетные данные для офлайн режима
  static final Map<String, String> testCredentials = {
    'email': 'test@example.com',
    'password': 'password123',
  };

  // Тестовые данные для офлайн режима
  static final Map<String, dynamic> testUser = {
    'id': '1',
    'email': 'test@example.com',
    'is_active': true,
    'is_superuser': false,
    'is_verified': true,
  };

  static final List<Map<String, dynamic>> testArticles = [
    {
      'id': 1,
      'title': 'Как подготовиться к собеседованию',
      'content': 'Подробное руководство по подготовке к собеседованию...',
      'created_at': '2024-03-20T10:00:00Z',
    },
    {
      'id': 2,
      'title': 'Топ-10 вопросов на собеседовании',
      'content': 'Самые частые вопросы и правильные ответы...',
      'created_at': '2024-03-19T15:30:00Z',
    },
  ];

  static final List<Map<String, dynamic>> testTests = [
    {
      'id': 1,
      'title': 'Базовый тест по Python',
      'description': 'Проверьте свои знания основ Python',
      'questions': [
        {
          'id': 1,
          'text': 'Что такое Python?',
          'options': [
            {'id': 1, 'text': 'Язык программирования'},
            {'id': 2, 'text': 'Змея'},
            {'id': 3, 'text': 'Редактор кода'},
          ],
          'correct_option_id': 1,
        },
      ],
    },
  ];

  static final List<Map<String, dynamic>> testHistory = [
    {
      'id': 1,
      'test_id': 1,
      'test_title': 'Базовый тест по Python',
      'score': 80,
      'completed_at': '2024-03-20T14:30:00Z',
    },
  ];
}
