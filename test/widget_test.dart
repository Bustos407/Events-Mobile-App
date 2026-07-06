import 'package:flutter_test/flutter_test.dart';

import 'package:event_finder/main.dart';

void main() {
  testWidgets('App shows login screen when no session exists', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
