// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:story_zoo/main.dart';

void main() {
  testWidgets('Story Zoo app launches successfully', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const StoryZooApp());

    // Verify that the welcome screen loads
    // Avoid pumpAndSettle because the UI contains animations.
    await tester.pump(const Duration(milliseconds: 800));
    
    // Check for welcome text
    expect(find.text('Karibu Story Zoo! 🦁'), findsOneWidget);
  });
}
