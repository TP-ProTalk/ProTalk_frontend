// test/widget/user_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:protalk_frontend/frames/user_screen.dart';

void main() {
  testWidgets('UserScreen renders and toggles edit mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: UserScreen()));

    // Проверка текста
    expect(find.text('ФИО'), findsOneWidget);
    expect(find.text('Почта'), findsOneWidget);
    expect(find.text('Иванов Иван Иванович'), findsOneWidget);

    // Нажимаем на кнопку редактирования
    await tester.tap(find.byIcon(Icons.edit));
    await tester.pump();

    // Теперь должен появиться TextFormField
    expect(find.byType(TextFormField), findsNWidgets(4));
  });
}
