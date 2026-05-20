import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/data/mock_sign_repository.dart';
import 'package:ishara/main.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await MockSignRepository.ensureLoaded();
  });

  testWidgets('home screen shows Ishara and search', (WidgetTester tester) async {
    await tester.pumpWidget(const IsharaApp());

    expect(find.text('Ishara'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Nepali'), findsOneWidget);
  });

  testWidgets('search navigates to results', (WidgetTester tester) async {
    await tester.pumpWidget(const IsharaApp());

    await tester.enterText(find.byType(TextField), 'hello');
    await tester.tap(find.byIcon(Icons.arrow_forward));
    await tester.pumpAndSettle();

    expect(find.text('Hello'), findsOneWidget);
    expect(find.textContaining('नमस्ते'), findsOneWidget);
  });
}
