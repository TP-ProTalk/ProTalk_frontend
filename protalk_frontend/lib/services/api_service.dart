import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:protalk_frontend/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String _baseUrl = dotenv.env['API_URL'] ?? 'http://103.74.94.53:8000';
  final _storage = const FlutterSecureStorage();
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // Инициализация SharedPreferences
  Future<void> _initPrefs() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // Метод для проверки офлайн режима
  bool _isOfflineMode() {
    return AppConfig.offlineMode;
  }

  // Метод для имитации задержки сети
  Future<void> _simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  // Метод для сохранения данных в кэш
  Future<void> _saveToCache(String key, dynamic data) async {
    try {
      await _storage.write(key: key, value: json.encode(data));
    } catch (e) {
      print('Ошибка сохранения в кэш: $e');
    }
  }

  // Метод для получения данных из кэша
  Future<dynamic> _getFromCache(String key) async {
    try {
      final data = await _storage.read(key: key);
      if (data != null) {
        return json.decode(data);
      }
    } catch (e) {
      print('Ошибка чтения из кэша: $e');
    }
    return null;
  }

  // Метод для логирования запросов
  void _logRequest(String method, String url, Map<String, String> headers,
      [dynamic body]) {
    print('=== API Request ===');
    print('Method: $method');
    print('URL: $url');
    print('Headers: $headers');
    if (body != null) {
      print('Body: $body');
    }
    print('==================');
  }

  // Метод для логирования ответов
  void _logResponse(int statusCode, String body) {
    print('=== API Response ===');
    print('Status Code: $statusCode');
    print('Body: $body');
    print('===================');
  }

  // Аутентификация
  Future<Map<String, dynamic>> login(String email, String password) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      if (email == AppConfig.testCredentials['email'] &&
          password == AppConfig.testCredentials['password']) {
        return {
          'access_token': 'offline_token',
          'token_type': 'bearer',
          'user_id': '1',
        };
      } else {
        throw Exception('Неверный email или пароль');
      }
    }

    try {
      final url = '$_baseUrl/api/auth/token';
      final headers = {'Content-Type': 'application/x-www-form-urlencoded'};
      final body = {
        'username': email,
        'password': password,
      };

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['user_id'] != null) {
          data['user_id'] = data['user_id'].toString();
        }
        await _saveToCache('user_data', data);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка авторизации: ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      final cachedData = await _getFromCache('user_data');
      if (cachedData != null) {
        return Map<String, dynamic>.from(cachedData);
      }
      rethrow;
    }
  }

  Future<String?> register(String email, String password) async {
    try {
      final url = '$_baseUrl/api/auth/register';
      final headers = {'Content-Type': 'application/json'};
      final body = {
        'email': email,
        'password': password,
      };

      _logRequest('POST', url, headers, body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      _logResponse(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // После успешной регистрации делаем запрос на получение токена
        final tokenUrl = '$_baseUrl/api/auth/token';
        final tokenHeaders = {
          'Content-Type': 'application/x-www-form-urlencoded'
        };
        final tokenBody = {
          'username': email,
          'password': password,
        };

        _logRequest('POST', tokenUrl, tokenHeaders, tokenBody);

        final tokenResponse = await http.post(
          Uri.parse(tokenUrl),
          headers: tokenHeaders,
          body: tokenBody,
        );

        _logResponse(tokenResponse.statusCode, tokenResponse.body);

        if (tokenResponse.statusCode == 200) {
          final tokenData = jsonDecode(tokenResponse.body);
          final token = tokenData['access_token'];
          if (token != null) {
            await _saveToCache('user_data', {
              'access_token': token,
              'token_type': 'bearer',
              'email': email,
              'user_id': tokenData['user_id']?.toString(),
            });
            return token;
          }
        }
        throw Exception('Не удалось получить токен после регистрации');
      } else if (response.statusCode == 422) {
        final data = jsonDecode(response.body);
        throw Exception(data['detail'] ?? 'Ошибка валидации');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        final errorMessage = data['detail'] ?? 'Неизвестная ошибка';
        print('Ошибка регистрации: $errorMessage');
        throw Exception(errorMessage);
      } else {
        final errorMessage =
            'Ошибка регистрации: ${response.statusCode} - ${response.body}';
        print(errorMessage);
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Register error: $e');
      throw Exception('Ошибка регистрации: $e');
    }
  }

  // Получение статей
  Future<List<Map<String, dynamic>>> getArticles(String token) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return List<Map<String, dynamic>>.from(AppConfig.testArticles);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final articles = data.map((article) {
          final Map<String, dynamic> articleMap =
              Map<String, dynamic>.from(article);
          // Преобразуем id в строку, если он есть
          if (articleMap['id'] != null) {
            articleMap['id'] = articleMap['id'].toString();
          }
          return articleMap;
        }).toList();
        await _saveToCache('articles', articles);
        return articles;
      } else {
        throw Exception('Ошибка получения статей: ${response.body}');
      }
    } catch (e) {
      // При ошибке сети пробуем получить данные из кэша
      final cachedArticles = await _getFromCache('articles');
      if (cachedArticles != null) {
        return List<Map<String, dynamic>>.from(cachedArticles);
      }
      // Если кэш пуст, возвращаем тестовые данные
      return List<Map<String, dynamic>>.from(AppConfig.testArticles);
    }
  }

  // Получение конкретной статьи
  Future<Map<String, dynamic>> getArticle(
      String token, String articleId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      // Возвращаем тестовую статью
      return {
        'id': articleId,
        'title': 'Тестовая статья $articleId',
        'content':
            'Это тестовое содержимое статьи $articleId. В офлайн режиме мы показываем тестовые данные.',
        'author': 'Тестовый автор',
        'date': DateTime.now().toIso8601String(),
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles/$articleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToCache('article_$articleId', data);
        return data;
      } else {
        // При ошибке пробуем получить данные из кэша
        final cachedArticle = await _getFromCache('article_$articleId');
        if (cachedArticle != null) {
          return Map<String, dynamic>.from(cachedArticle);
        }
        throw Exception('Ошибка получения статьи: ${response.body}');
      }
    } catch (e) {
      // При ошибке сети пробуем получить данные из кэша
      final cachedArticle = await _getFromCache('article_$articleId');
      if (cachedArticle != null) {
        return Map<String, dynamic>.from(cachedArticle);
      }
      // Если кэш пуст, возвращаем тестовые данные
      return {
        'id': articleId,
        'title': 'Тестовая статья $articleId',
        'content':
            'Это тестовое содержимое статьи $articleId. В офлайн режиме мы показываем тестовые данные.',
        'author': 'Тестовый автор',
        'date': DateTime.now().toIso8601String(),
      };
    }
  }

  // Получение комментариев к статье
  Future<List<Map<String, dynamic>>> getArticleComments(
    String token,
    String articleId,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      // Возвращаем тестовые комментарии
      return [
        {
          'id': '1',
          'text': 'Тестовый комментарий 1',
          'author': 'Тестовый пользователь 1',
          'date': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'text': 'Тестовый комментарий 2',
          'author': 'Тестовый пользователь 2',
          'date': DateTime.now().toIso8601String(),
        },
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/articles/$articleId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final comments = data.cast<Map<String, dynamic>>();
        await _saveToCache('comments_$articleId', comments);
        return comments;
      } else {
        // При ошибке пробуем получить данные из кэша
        final cachedComments = await _getFromCache('comments_$articleId');
        if (cachedComments != null) {
          return List<Map<String, dynamic>>.from(cachedComments);
        }
        throw Exception('Ошибка получения комментариев: ${response.body}');
      }
    } catch (e) {
      // При ошибке сети пробуем получить данные из кэша
      final cachedComments = await _getFromCache('comments_$articleId');
      if (cachedComments != null) {
        return List<Map<String, dynamic>>.from(cachedComments);
      }
      // Если кэш пуст, возвращаем тестовые данные
      return [
        {
          'id': '1',
          'text': 'Тестовый комментарий 1',
          'author': 'Тестовый пользователь 1',
          'date': DateTime.now().toIso8601String(),
        },
        {
          'id': '2',
          'text': 'Тестовый комментарий 2',
          'author': 'Тестовый пользователь 2',
          'date': DateTime.now().toIso8601String(),
        },
      ];
    }
  }

  // Добавление комментария
  Future<Map<String, dynamic>> addComment(
    String token,
    String articleId,
    String text,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      // В офлайн режиме создаем тестовый комментарий
      final comment = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'text': text,
        'author': 'Тестовый пользователь',
        'date': DateTime.now().toIso8601String(),
      };
      // Сохраняем комментарий в кэш
      final cachedComments = await _getFromCache('comments_$articleId') ?? [];
      cachedComments.add(comment);
      await _saveToCache('comments_$articleId', cachedComments);
      return comment;
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/articles/$articleId/comments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 201) {
        final comment = json.decode(response.body);
        // Обновляем кэш комментариев
        final cachedComments = await _getFromCache('comments_$articleId') ?? [];
        cachedComments.add(comment);
        await _saveToCache('comments_$articleId', cachedComments);
        return comment;
      } else {
        throw Exception('Ошибка добавления комментария: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка добавления комментария: $e');
    }
  }

  // Получение тестов
  Future<List<Map<String, dynamic>>> getTests(
    String token, {
    int skip = 0,
    int limit = 100,
  }) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return List<Map<String, dynamic>>.from(AppConfig.testTests);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tests/?skip=$skip&limit=$limit'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tests = data.map((test) {
          final Map<String, dynamic> testMap = Map<String, dynamic>.from(test);
          // Преобразуем id в строку, если он есть
          if (testMap['id'] != null) {
            testMap['id'] = testMap['id'].toString();
          }
          if (testMap['vacancy_id'] != null) {
            testMap['vacancy_id'] = testMap['vacancy_id'].toString();
          }
          // Обработка nullable полей
          testMap['name'] = testMap['name'] ?? '';
          testMap['description'] = testMap['description'] ?? '';
          testMap['grade'] = testMap['grade'] ?? '';
          return testMap;
        }).toList();
        await _saveToCache('tests', tests);
        return tests;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка получения тестов: ${response.body}');
      }
    } catch (e) {
      final cachedTests = await _getFromCache('tests');
      if (cachedTests != null) {
        return List<Map<String, dynamic>>.from(cachedTests);
      }
      return List<Map<String, dynamic>>.from(AppConfig.testTests);
    }
  }

  // Получение теста по ID
  Future<Map<String, dynamic>> getTestById(String token, String testId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return AppConfig.testTests.firstWhere(
        (test) => test['id'].toString() == testId,
        orElse: () => {},
      );
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tests/$testId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        // Преобразуем id вопросов и вариантов ответов
        if (data['questions'] != null) {
          data['questions'] = (data['questions'] as List).map((question) {
            final Map<String, dynamic> questionMap =
                Map<String, dynamic>.from(question);
            if (questionMap['id'] != null) {
              questionMap['id'] = questionMap['id'].toString();
            }
            if (questionMap['correct_option_id'] != null) {
              questionMap['correct_option_id'] =
                  questionMap['correct_option_id'].toString();
            }
            if (questionMap['options'] != null) {
              questionMap['options'] =
                  (questionMap['options'] as List).map((option) {
                final Map<String, dynamic> optionMap =
                    Map<String, dynamic>.from(option);
                if (optionMap['id'] != null) {
                  optionMap['id'] = optionMap['id'].toString();
                }
                return optionMap;
              }).toList();
            }
            return questionMap;
          }).toList();
        }
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка получения теста: ${response.body}');
      }
    } catch (e) {
      return AppConfig.testTests.firstWhere(
        (test) => test['id'].toString() == testId,
        orElse: () => {},
      );
    }
  }

  // Создание теста
  Future<Map<String, dynamic>> createTest(
    String token,
    Map<String, dynamic> testData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': '1',
        ...testData,
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/tests/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(testData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        // Обновляем кэш тестов
        final tests = await getTests(token);
        await _saveToCache('tests', tests);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка создания теста: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Обновление теста
  Future<Map<String, dynamic>> updateTest(
    String token,
    String testId,
    Map<String, dynamic> testData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': testId,
        ...testData,
      };
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/tests/$testId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(testData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        // Обновляем кэш тестов
        final tests = await getTests(token);
        await _saveToCache('tests', tests);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка обновления теста: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Удаление теста
  Future<void> deleteTest(String token, String testId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/tests/$testId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Обновляем кэш тестов
        final tests = await getTests(token);
        await _saveToCache('tests', tests);
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка удаления теста: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Отправка ответов на тест
  Future<Map<String, dynamic>> submitTest(
    String token,
    int testId,
    List<Map<String, dynamic>> answers,
  ) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/api/tests/$testId/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'answers': answers}),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Ошибка отправки теста: ${response.body}');
    }
  }

  // Получение истории тестов
  Future<List<Map<String, dynamic>>> getTestHistory(String token) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return List<Map<String, dynamic>>.from(AppConfig.testHistory);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tests/history'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final history = data.map((item) {
          final Map<String, dynamic> historyMap =
              Map<String, dynamic>.from(item);
          // Преобразуем id в строку, если он есть
          if (historyMap['id'] != null) {
            historyMap['id'] = historyMap['id'].toString();
          }
          if (historyMap['test_id'] != null) {
            historyMap['test_id'] = historyMap['test_id'].toString();
          }
          return historyMap;
        }).toList();
        await _saveToCache('test_history', history);
        return history;
      } else {
        throw Exception('Ошибка получения истории тестов: ${response.body}');
      }
    } catch (e) {
      // При ошибке сети пробуем получить данные из кэша
      final cachedHistory = await _getFromCache('test_history');
      if (cachedHistory != null) {
        return List<Map<String, dynamic>>.from(cachedHistory);
      }
      // Если кэш пуст, возвращаем тестовые данные
      return List<Map<String, dynamic>>.from(AppConfig.testHistory);
    }
  }

  // Получение профиля текущего пользователя
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'name': 'Тестовый пользователь',
        'surname': 'Тестовый',
        'patronymic': 'Тестович',
        'email': 'test@example.com',
        'phone': '+7 (999) 999-99-99',
        'birth_date': '1990-01-01',
        'main_vacancy': '1',
        'secondary_vacancy1': '2',
        'secondary_vacancy2': '3',
        'grade': 'Middle',
        'experience': 5,
        'education': 'Высшее техническое',
        'skills': 'Python, Java, Flutter',
        'about': 'Тестовый профиль',
      };
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToCache('user_profile', data);
        return data;
      } else {
        throw Exception('Ошибка получения профиля: ${response.body}');
      }
    } catch (e) {
      final cachedProfile = await _getFromCache('user_profile');
      if (cachedProfile != null) {
        return Map<String, dynamic>.from(cachedProfile);
      }
      throw Exception('Ошибка получения профиля: $e');
    }
  }

  // Обновление профиля пользователя
  Future<void> updateUserProfile(
      String token, Map<String, dynamic> profileData) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      await _saveToCache('user_profile', profileData);
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/users/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(profileData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await _saveToCache('user_profile', data);
      } else {
        throw Exception('Ошибка обновления профиля: ${response.body}');
      }
    } catch (e) {
      throw Exception('Ошибка обновления профиля: $e');
    }
  }

  // Получение профиля пользователя по ID
  Future<Map<String, dynamic>> getUserById(String token, String userId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return Map<String, dynamic>.from(AppConfig.testUser);
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/users/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception(
            'Ошибка получения профиля пользователя: ${response.body}');
      }
    } catch (e) {
      // При ошибке возвращаем тестовые данные
      return Map<String, dynamic>.from(AppConfig.testUser);
    }
  }

  // Получение списка вакансий
  Future<List<Map<String, dynamic>>> getVacancies(String token) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return [
        {'id': '1', 'title': 'Python Developer'},
        {'id': '2', 'title': 'Java Developer'},
        {'id': '3', 'title': 'Frontend Developer'},
        {'id': '4', 'title': 'Backend Developer'},
        {'id': '5', 'title': 'DevOps Engineer'},
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/vacancies'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final vacancies = data.map((vacancy) {
          final Map<String, dynamic> vacancyMap =
              Map<String, dynamic>.from(vacancy);
          if (vacancyMap['id'] != null) {
            vacancyMap['id'] = vacancyMap['id'].toString();
          }
          return vacancyMap;
        }).toList();
        await _saveToCache('vacancies', vacancies);
        return vacancies;
      } else {
        throw Exception('Ошибка получения вакансий: ${response.body}');
      }
    } catch (e) {
      final cachedVacancies = await _getFromCache('vacancies');
      if (cachedVacancies != null) {
        return List<Map<String, dynamic>>.from(cachedVacancies);
      }
      return [
        {'id': '1', 'title': 'Python Developer'},
        {'id': '2', 'title': 'Java Developer'},
        {'id': '3', 'title': 'Frontend Developer'},
        {'id': '4', 'title': 'Backend Developer'},
        {'id': '5', 'title': 'DevOps Engineer'},
      ];
    }
  }

  // Получение вакансии по ID
  Future<Map<String, dynamic>> getVacancyById(
      String token, String vacancyId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {};
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/vacancies/$vacancyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка получения вакансии: ${response.body}');
      }
    } catch (e) {
      return {};
    }
  }

  // Создание вакансии
  Future<Map<String, dynamic>> createVacancy(
    String token,
    Map<String, dynamic> vacancyData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': '1',
        ...vacancyData,
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/vacancies/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vacancyData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        // Обновляем кэш вакансий
        final vacancies = await getVacancies(token);
        await _saveToCache('vacancies', vacancies);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка создания вакансии: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Обновление вакансии
  Future<Map<String, dynamic>> updateVacancy(
    String token,
    String vacancyId,
    Map<String, dynamic> vacancyData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': vacancyId,
        ...vacancyData,
      };
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/vacancies/$vacancyId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(vacancyData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        // Обновляем кэш вакансий
        final vacancies = await getVacancies(token);
        await _saveToCache('vacancies', vacancies);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка обновления вакансии: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Удаление вакансии
  Future<void> deleteVacancy(String token, String vacancyId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/vacancies/$vacancyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Обновляем кэш вакансий
        final vacancies = await getVacancies(token);
        await _saveToCache('vacancies', vacancies);
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка удаления вакансии: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Получение вопросов теста
  Future<List<Map<String, dynamic>>> getTestQuestions(
    String token,
    String testId,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return [
        {
          'id': '1',
          'test_id': testId,
          'question':
              'Какой паттерн проектирования используется для обеспечения единственного экземпляра класса?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correct_answer': 'Singleton',
        },
        {
          'id': '2',
          'test_id': testId,
          'question':
              'Какой паттерн проектирования используется для определения семейства алгоритмов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correct_answer': 'Strategy',
        },
        {
          'id': '3',
          'test_id': testId,
          'question':
              'Какой паттерн проектирования используется для создания объектов?',
          'answers': ['Factory Method', 'Observer', 'Singleton', 'Strategy'],
          'correct_answer': 'Factory Method',
        },
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/questions/test/$testId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final questions = data.map((question) {
          final Map<String, dynamic> questionMap =
              Map<String, dynamic>.from(question);
          // Преобразуем id в строку, если он есть
          if (questionMap['id'] != null) {
            questionMap['id'] = questionMap['id'].toString();
          }
          if (questionMap['test_id'] != null) {
            questionMap['test_id'] = questionMap['test_id'].toString();
          }
          if (questionMap['knowledge_id'] != null) {
            questionMap['knowledge_id'] =
                questionMap['knowledge_id'].toString();
          }
          // Обработка nullable полей
          questionMap['question'] = questionMap['question'] ?? '';
          questionMap['correct_answer'] = questionMap['correct_answer'] ?? '';
          return questionMap;
        }).toList();
        await _saveToCache('test_questions_$testId', questions);
        return questions;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка получения вопросов теста: ${response.body}');
      }
    } catch (e) {
      final cachedQuestions = await _getFromCache('test_questions_$testId');
      if (cachedQuestions != null) {
        return List<Map<String, dynamic>>.from(cachedQuestions);
      }
      return [];
    }
  }

  // Создание вопроса
  Future<Map<String, dynamic>> createQuestion(
    String token,
    Map<String, dynamic> questionData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': '1',
        'question': questionData['question'] ?? '',
        'test_id': questionData['test_id']?.toString() ?? '',
        'correct_answer': questionData['correct_answer'] ?? '',
        'knowledge_id': questionData['knowledge_id']?.toString(),
      };
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/questions/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(questionData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        if (data['test_id'] != null) {
          data['test_id'] = data['test_id'].toString();
        }
        if (data['knowledge_id'] != null) {
          data['knowledge_id'] = data['knowledge_id'].toString();
        }
        // Обработка nullable полей
        data['question'] = data['question'] ?? '';
        data['correct_answer'] = data['correct_answer'] ?? '';
        // Обновляем кэш вопросов для теста
        final questions = await getTestQuestions(token, data['test_id']);
        await _saveToCache('test_questions_${data['test_id']}', questions);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка создания вопроса: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Обновление вопроса
  Future<Map<String, dynamic>> updateQuestion(
    String token,
    String questionId,
    Map<String, dynamic> questionData,
  ) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return {
        'id': questionId,
        'question': questionData['question'] ?? '',
        'test_id': questionData['test_id']?.toString() ?? '',
        'correct_answer': questionData['correct_answer'] ?? '',
        'knowledge_id': questionData['knowledge_id']?.toString(),
      };
    }

    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/questions/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(questionData),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Преобразуем id в строку, если он есть
        if (data['id'] != null) {
          data['id'] = data['id'].toString();
        }
        if (data['test_id'] != null) {
          data['test_id'] = data['test_id'].toString();
        }
        if (data['knowledge_id'] != null) {
          data['knowledge_id'] = data['knowledge_id'].toString();
        }
        // Обработка nullable полей
        data['question'] = data['question'] ?? '';
        data['correct_answer'] = data['correct_answer'] ?? '';
        // Обновляем кэш вопросов для теста
        final questions = await getTestQuestions(token, data['test_id']);
        await _saveToCache('test_questions_${data['test_id']}', questions);
        return data;
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка обновления вопроса: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Удаление вопроса
  Future<void> deleteQuestion(String token, String questionId) async {
    if (_isOfflineMode()) {
      await _simulateNetworkDelay();
      return;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/questions/$questionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Получаем test_id из кэша
        final cachedQuestions =
            await _getFromCache('test_questions_$questionId');
        if (cachedQuestions != null && cachedQuestions.isNotEmpty) {
          final testId = cachedQuestions[0]['test_id'];
          // Обновляем кэш вопросов для теста
          final questions = await getTestQuestions(token, testId);
          await _saveToCache('test_questions_$testId', questions);
        }
      } else if (response.statusCode == 422) {
        final responseBody = json.decode(response.body);
        if (responseBody['detail'] != null) {
          throw Exception(responseBody['detail'].toString());
        }
        throw Exception('Ошибка валидации данных');
      } else {
        throw Exception('Ошибка удаления вопроса: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
