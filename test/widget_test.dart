import 'package:flutter_test/flutter_test.dart';
import 'package:jvtus_timetable/main.dart';

void main() {
  testWidgets('App launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TimetableApp());
    expect(find.text('我的课表'), findsOneWidget);
  });
}
