import 'package:flutter_test/flutter_test.dart';
import 'package:desktop_print_app/app.dart';

void main() {
  testWidgets('App renders without crashing', (tester) async {
    await tester.pumpWidget(const PrintApp());
    expect(find.byType(PrintApp), findsOneWidget);
  });
}
