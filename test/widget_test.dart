import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:badminton_score/main.dart';

void main() {
  testWidgets('App renders a blank white screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(Scaffold), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, Colors.white);
  });
}
