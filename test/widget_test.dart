import 'package:flutter_test/flutter_test.dart';
import 'package:task_flow/main.dart';

void main() {
  testWidgets('App launches and shows title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is present.
    expect(find.text('TaskFlow'), findsOneWidget);
  });
}