import 'package:flutter_test/flutter_test.dart';
import 'package:tiku_muban/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const TikuApp());
    await tester.pump();

    expect(find.byType(TikuApp), findsOneWidget);
  });
}
