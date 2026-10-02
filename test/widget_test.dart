import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:segment_display/segment_display.dart';

import 'package:badminton_score/main.dart';
import 'package:badminton_score/theme/app_theme.dart';

List<String> displayedScores(WidgetTester tester) {
  return tester
      .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
      .map((display) => display.value)
      .toList();
}

void main() {
  testWidgets('Score scaffold renders midnight theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Dark background from the midnight palette.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull); // comes from ThemeData
    expect(AppTheme.current.background, const Color(0xFF09090B));

    // Row 1: two seven-segment score displays showing 0.
    expect(find.byType(SevenSegmentDisplay), findsNWidgets(2));
    expect(displayedScores(tester), ['0', '0']);

    // Row 2: two minus buttons and one settings button.
    expect(find.byIcon(LucideIcons.minus), findsNWidgets(2));
    expect(find.byIcon(LucideIcons.settings), findsOneWidget);
  });

  testWidgets('Tapping a score panel increments it', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('leftScorePanel')));
    await tester.pump();

    expect(displayedScores(tester), ['1', '0']);
  });

  testWidgets('Minus button decrements the score', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('rightScorePanel')));
    await tester.pump();
    expect(displayedScores(tester), ['0', '1']);

    await tester.tap(find.byIcon(LucideIcons.minus).last);
    await tester.pump();
    expect(displayedScores(tester), ['0', '0']);
  });
}
