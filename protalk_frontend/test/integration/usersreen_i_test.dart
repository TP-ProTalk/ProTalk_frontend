// integration_test/user_screen_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:protalk_frontend/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('UserScreen logout flow works', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Предполагаем, что UserScreen уже открыт
    expect(find.text('Профиль'), findsOneWidget);

    // Нажимаем "Выйти из аккаунта"
    await tester.tap(find.text('Выйти из аккаунта'));
    await tester.pumpAndSettle();

    // Должно появиться диалоговое окно
    expect(find.text('Подтверждение выхода'), findsOneWidget);

    // Подтверждаем выход
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();

    // Проверяем переход на SplashScreen (можно по ключу или заголовку)
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
