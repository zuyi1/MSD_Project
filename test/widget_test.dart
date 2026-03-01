import 'package:flutter_test/flutter_test.dart';
import 'package:food_diary_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FoodDiaryApp());

    // Verify that we are on the Diary screen (the default).
    expect(find.text('Food Diary'), findsOneWidget);
    expect(find.text('No entries yet. Tap + to add one!'), findsOneWidget);
  });
}
