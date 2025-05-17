import 'package:flutter/material.dart';
import 'package:protalk_frontend/data/test_article.dart';
import 'article_screen.dart' as article;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import 'package:protalk_frontend/services/api_service.dart';
import 'package:protalk_frontend/services/auth_service.dart';
import 'package:protalk_frontend/frames/article_screen.dart';

void main() {
  runApp(const Knowledgebase());
}

class Knowledgebase extends StatelessWidget {
  const Knowledgebase({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFD9CCB7),
      ),
      home: Scaffold(body: const ModeSelectionScreen()),
    );
  }
}

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool _softSelected = false;
  bool _hardSelected = false;
  String? _selectedMode;
  int? _selectedTheme;

  final List<String> _softThemes = ['Тема 1', 'Тема 2', 'Тема 3'];
  final List<String> _hardThemes = ['Тема A', 'Тема B', 'Тема C'];

  static const Color accentColor = Color.fromARGB(255, 127, 113, 179);
  static const Color accentLightColor = Color.fromARGB(255, 157, 144, 209);
  static const Color neutralColor = Color.fromARGB(255, 50, 40, 70);

  void _selectSoft() {
    setState(() {
      _softSelected = true;
      _hardSelected = false;
      _selectedMode = 'Soft';
      _selectedTheme = null;
    });
  }

  void _selectHard() {
    setState(() {
      _softSelected = false;
      _hardSelected = true;
      _selectedMode = 'Hard';
      _selectedTheme = null;
    });
  }

  void _selectTheme(int themeIndex) {
    setState(() {
      _selectedTheme = themeIndex;
    });
  }

  void _navigateToArticleScreen(int articleNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArticleScreen(
          mode: _selectedMode!,
          theme: _softSelected
              ? _softThemes[_selectedTheme!]
              : _hardThemes[_selectedTheme!],
          articleNumber: articleNumber.toString(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Кнопка Soft
            ElevatedButton(
              onPressed: _selectSoft,
              style: ElevatedButton.styleFrom(
                backgroundColor: _softSelected ? accentLightColor : accentColor,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Soft Skills',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 15),

            // Кнопка Hard
            ElevatedButton(
              onPressed: _selectHard,
              style: ElevatedButton.styleFrom(
                backgroundColor: _hardSelected ? accentLightColor : accentColor,
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 6,
                shadowColor: Colors.black45,
              ),
              child: const Text(
                'Hard Skills',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 30),

            if (_softSelected || _hardSelected)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: (_softSelected ? _softThemes : _hardThemes)
                        .asMap()
                        .entries
                        .map((entry) {
                      final index = entry.key;
                      final theme = entry.value;
                      final isSelected = _selectedTheme == index;

                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 50,
                              vertical: 5,
                            ),
                            child: ElevatedButton(
                              onPressed: () => _selectTheme(index),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? accentLightColor
                                    : neutralColor,
                                minimumSize: const Size(
                                  double.infinity,
                                  50,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                ),
                              ),
                              child: Text(
                                theme,
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (isSelected)
                            Column(
                              children: List.generate(3, (i) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 70,
                                    vertical: 5,
                                  ),
                                  child: ElevatedButton(
                                    onPressed: () => _navigateToArticleScreen(
                                      i + 1,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: accentColor,
                                      minimumSize: const Size(
                                        double.infinity,
                                        40,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    child: Text(
                                      'Статья ${i + 1}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ArticleScreen extends StatefulWidget {
  final String mode;
  final String theme;
  final String articleNumber;

  const ArticleScreen({
    super.key,
    required this.mode,
    required this.theme,
    required this.articleNumber,
  });

  @override
  State<ArticleScreen> createState() => _ArticleScreenState();
}

class _ArticleScreenState extends State<ArticleScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  Map<String, dynamic>? _article;
  bool _isLoading = true;
  String? _error;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadArticle();
  }

  Future<void> _loadArticle() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final article = await _apiService.getArticle(token, widget.articleNumber);
      final comments = await _apiService.getArticleComments(
        token,
        widget.articleNumber,
      );

      setState(() {
        _article = {
          'id': article['id']?.toString() ?? '',
          'title': article['title'] ?? 'Без названия',
          'content': article['content'] ?? 'Нет содержимого',
          'author': article['author'] ?? 'Неизвестный автор',
          'date': article['date'] ?? DateTime.now().toIso8601String(),
        };
        _comments = comments.map((comment) {
          return {
            'id': comment['id']?.toString() ?? '',
            'text': comment['text'] ?? '',
            'author': comment['author'] ?? 'Неизвестный автор',
            'date': comment['date'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final comment = await _apiService.addComment(
        token,
        widget.articleNumber,
        _commentController.text,
      );

      setState(() {
        _comments.add({
          'id': comment['id']?.toString() ?? '',
          'text': comment['text'] ?? '',
          'author': comment['author'] ?? 'Неизвестный автор',
          'date': comment['date'] ?? DateTime.now().toIso8601String(),
        });
      });
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении комментария: $e')),
      );
    }
  }

  void _shareArticle() {
    if (_article == null) return;

    Share.share(
      '${_article!['title']}\n\n${_article!['content']}\n\nАвтор: ${_article!['author']}\nДата: ${_article!['date']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE9),
      appBar: AppBar(
        title: Text('${widget.mode} - ${widget.theme}'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(80, 0, 0, 0),
        elevation: 1,
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: _shareArticle),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _article!['title'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _article!['author'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(width: 15),
                                const Icon(
                                  Icons.calendar_today,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  _article!['date'],
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          _article!['content'],
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Комментарии',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),
                            ..._comments
                                .map(
                                  (comment) => Card(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.person,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                comment['author'],
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                DateTime.parse(
                                                  comment['date'],
                                                ).toString().split('.')[0],
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          Text(comment['text']),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            const SizedBox(height: 15),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: const InputDecoration(
                                      hintText: 'Написать комментарий...',
                                      border: OutlineInputBorder(),
                                    ),
                                    maxLines: 3,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: _addComment,
                                  icon: const Icon(Icons.send),
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

class KnowledgeBaseScreen extends StatefulWidget {
  const KnowledgeBaseScreen({super.key});

  @override
  State<KnowledgeBaseScreen> createState() => _KnowledgeBaseScreenState();
}

class _KnowledgeBaseScreenState extends State<KnowledgeBaseScreen> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _articles = [];
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadArticles();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('Требуется авторизация');
      }

      final articles = await _apiService.getArticles(token);

      setState(() {
        _articles = articles.map((article) {
          return {
            'id': article['id']?.toString() ?? '',
            'title': article['title'] ?? 'Без названия',
            'description': article['description'] ?? 'Нет описания',
            'content': article['content'] ?? 'Нет содержимого',
            'author': article['author'] ?? 'Неизвестный автор',
            'date': article['date'] ?? DateTime.now().toIso8601String(),
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD9CCB7),
      appBar: AppBar(
        title: const Text(
          'База знаний',
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
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : _articles.isEmpty
                  ? const Center(
                      child: Text(
                        'Статьи не найдены',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontFamily: 'Cuyabra',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _articles.length,
                      itemBuilder: (context, index) {
                        final article = _articles[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            title: Text(
                              article['title'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Cuyabra',
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                Text(
                                  article['description'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Cuyabra',
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.person,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      article['author'],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Cuyabra',
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    const Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      DateTime.parse(article['date'])
                                          .toString()
                                          .split('.')[0],
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontFamily: 'Cuyabra',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ArticleScreen(
                                    articleNumber: article['id'].toString(),
                                    mode: 'База знаний',
                                    theme: article['title'],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
    );
  }
}
