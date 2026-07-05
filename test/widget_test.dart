import 'package:flutter_test/flutter_test.dart';
import 'package:taskquest/main.dart';

void main() {
  testWidgets('App renders login screen initially', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that the login screen elements are shown.
    expect(find.text('TaskQuest'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
