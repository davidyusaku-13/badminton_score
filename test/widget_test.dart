import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:segment_display/segment_display.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:badminton_score/main.dart';
import 'package:badminton_score/theme/app_theme.dart';

List<String> displayedScores(WidgetTester tester) {
  return tester
      .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
      .map((display) => display.value)
      .toList();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Score scaffold renders midnight theme', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    // Dark background from the midnight palette.
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, isNull); // comes from ThemeData
    expect(AppTheme.current.background, const Color(0xFF09090B));

    // Row 1: player names and two seven-segment score displays showing 0.
    expect(find.text('PLAYER 1'), findsOneWidget);
    expect(find.text('PLAYER 2'), findsOneWidget);
    expect(find.byType(SevenSegmentDisplay), findsNWidgets(2));
    expect(displayedScores(tester), ['0', '0']);

    // Row 2: two minus buttons plus undo, settings and reset.
    expect(find.byIcon(LucideIcons.minus), findsNWidgets(2));
    expect(find.byIcon(LucideIcons.undo2), findsOneWidget);
    expect(find.byIcon(LucideIcons.settings), findsOneWidget);
    expect(find.byIcon(LucideIcons.rotateCcw), findsOneWidget);
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

  testWidgets('Undo restores the previous score', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('leftScorePanel')));
    await tester.pump();
    expect(displayedScores(tester), ['1', '0']);

    await tester.tap(find.byIcon(LucideIcons.undo2));
    await tester.pump();
    expect(displayedScores(tester), ['0', '0']);
  });

  testWidgets('Settings can rename a player', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('settings-left-name')),
      'Andi',
    );
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('ANDI'), findsOneWidget);
    expect(find.text('PLAYER 1'), findsNothing);
  });

  testWidgets('Settings can recolor a side', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    // Orange is index 2 in kAccentChoices.
    await tester.tap(find.byKey(const Key('settings-left-color-2')));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final displays = tester
        .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
        .toList();
    expect(
      (displays[0].segmentStyle as DefaultSegmentStyle).enabledColor,
      const Color(0xFFFB923C),
    );
  });

  testWidgets('Settings can change score size', (WidgetTester tester) async {
    // Tall viewport so the whole dialog content is visible without scrolling.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    // Drag the slider to maximum (24).
    await tester.drag(
      find.byKey(const Key('settings-score-size')),
      const Offset(500, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final displays = tester
        .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
        .toList();
    for (final display in displays) {
      expect(display.size, 24.0);
    }
  });

  testWidgets('Custom color swatch opens the full palette', (
    WidgetTester tester,
  ) async {
    // Tall viewport so the whole palette dialog is visible without scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('settings-left-color-custom')));
    await tester.pumpAndSettle();
    expect(find.text('Pick a color'), findsOneWidget);

    // Red hue, shade 500.
    await tester.tap(find.byKey(const Key('custom-hue-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('custom-shade-5')));
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final displays = tester
        .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
        .toList();
    expect(
      (displays[0].segmentStyle as DefaultSegmentStyle).enabledColor,
      Colors.red[500],
    );
  });

  testWidgets('Reset asks for confirmation before clearing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('leftScorePanel')));
    await tester.pump();
    expect(displayedScores(tester), ['1', '0']);

    await tester.tap(find.byIcon(LucideIcons.rotateCcw));
    await tester.pumpAndSettle();
    expect(find.text('Reset game?'), findsOneWidget);

    // Cancel keeps the score.
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(displayedScores(tester), ['1', '0']);

    // Confirm clears the score.
    await tester.tap(find.byIcon(LucideIcons.rotateCcw));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset'));
    await tester.pumpAndSettle();
    expect(displayedScores(tester), ['0', '0']);
  });

  testWidgets('Sound can be muted from settings', (WidgetTester tester) async {
    // Tall viewport so the whole settings content is visible without scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();

    final soundSwitch = find.byKey(const Key('settings-sound'));
    expect(tester.widget<SwitchListTile>(soundSwitch).value, isTrue);

    await tester.tap(soundSwitch);
    await tester.pumpAndSettle();
    expect(tester.widget<SwitchListTile>(soundSwitch).value, isFalse);

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Scoring still works while muted.
    await tester.tap(find.byKey(const Key('leftScorePanel')));
    await tester.pump();
    expect(displayedScores(tester), ['1', '0']);
  });

  testWidgets('Reset to defaults restores factory settings', (
    WidgetTester tester,
  ) async {
    // Tall viewport so the whole settings content is visible without scrolling.
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());

    // Change everything away from defaults.
    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('settings-left-name')),
      'Andi',
    );
    await tester.tap(find.byKey(const Key('settings-left-color-2')));
    await tester.drag(
      find.byKey(const Key('settings-score-size')),
      const Offset(500, 0),
    );
    await tester.tap(find.byKey(const Key('settings-sound')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset to defaults'));
    await tester.pumpAndSettle();

    // Dialog shows defaults again.
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('settings-left-name')))
          .controller
          ?.text,
      'Player 1',
    );
    expect(find.text('Size: 14'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('settings-sound'))).value,
      isTrue,
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Main screen is back to defaults.
    expect(find.text('PLAYER 1'), findsOneWidget);
    final displays = tester
        .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
        .toList();
    expect(
      (displays[0].segmentStyle as DefaultSegmentStyle).enabledColor,
      const Color(0xFFA3E635),
    );
    for (final display in displays) {
      expect(display.size, 14.0);
    }
  });

  testWidgets('Loads persisted settings on startup', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'leftName': 'Andi',
      'leftColor': const Color(0xFFFB923C).toARGB32(),
      'scoreSize': 20.0,
      'soundEnabled': false,
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('ANDI'), findsOneWidget);
    final displays = tester
        .widgetList<SevenSegmentDisplay>(find.byType(SevenSegmentDisplay))
        .toList();
    expect(
      (displays[0].segmentStyle as DefaultSegmentStyle).enabledColor,
      const Color(0xFFFB923C),
    );
    for (final display in displays) {
      expect(display.size, 20.0);
    }

    await tester.tap(find.byIcon(LucideIcons.settings));
    await tester.pumpAndSettle();
    expect(
      tester.widget<SwitchListTile>(find.byKey(const Key('settings-sound'))).value,
      isFalse,
    );
  });

  testWidgets('Undo button looks disabled with empty history', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    Opacity undoOpacity() => tester.widget<Opacity>(
      find.ancestor(
        of: find.byIcon(LucideIcons.undo2),
        matching: find.byType(Opacity),
      ),
    );

    expect(undoOpacity().opacity, 0.4);

    await tester.tap(find.byKey(const Key('leftScorePanel')));
    await tester.pump();
    expect(undoOpacity().opacity, 1.0);
  });
}
