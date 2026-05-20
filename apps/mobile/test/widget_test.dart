import 'package:flutter_test/flutter_test.dart';
import 'package:ishara/main.dart';

void main() {
  testWidgets('shows app title', (WidgetTester tester) async {
    await tester.pumpWidget(const IsharaApp());
    expect(find.text('Ishara'), findsOneWidget);
  });
}
