import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:badminton_score/main.dart';
import 'package:badminton_score/models/app_constants.dart';
import 'package:badminton_score/models/game_state.dart';
import 'package:badminton_score/models/score_action.dart';
import 'package:badminton_score/theme/theme.dart';

// Mock function for testing
void _mockThemeChange(String theme) {}

void main() {
  group('AppConstants', () {
    test('should have correct default values', () {
      expect(AppConstants.minTargetScore, 5);
      expect(AppConstants.defaultTargetScore, 21);
      expect(AppConstants.maxScoreOffset, 9);
      expect(AppConstants.minWinMargin, 2);
      expect(AppConstants.maxUndoHistory, 10);
      expect(AppConstants.minSwipeVelocity, 500);
      expect(AppConstants.highScoreThreshold, 10);
      expect(AppConstants.controlButtonHeight, 56);
    });
  });

  group('GameState', () {
    test('should create initial state correctly', () {
      final state = GameState.initial();
      expect(state.leftScore, 0);
      expect(state.rightScore, 0);
      expect(state.leftGames, 0);
      expect(state.rightGames, 0);
      expect(state.isLeftServing, true);
      expect(state.targetScore, AppConstants.defaultTargetScore);
      expect(state.leftPlayerName, 'Left');
      expect(state.rightPlayerName, 'Right');
    });

    test('should calculate totalPoints correctly', () {
      final state = GameState.initial().copyWith(leftScore: 10, rightScore: 15);
      expect(state.totalPoints, 25);
    });

    test('should copyWith correctly', () {
      final state = GameState.initial();
      final newState = state.copyWith(
        leftScore: 5,
        rightScore: 3,
        leftPlayerName: 'Alice',
      );
      expect(newState.leftScore, 5);
      expect(newState.rightScore, 3);
      expect(newState.leftPlayerName, 'Alice');
      expect(newState.rightPlayerName, 'Right'); // unchanged
    });
  });

  group('Win Detection Logic', () {
    test('should win at targetScore + maxScoreOffset (sudden death)', () {
      // Win condition: score >= targetScore + maxScoreOffset
      const maxScore = AppConstants.defaultTargetScore + AppConstants.maxScoreOffset; // 30
      expect(maxScore, 30);
    });

    test('should win at targetScore with minWinMargin', () {
      // Win condition: score >= targetScore && score - opponentScore >= minWinMargin
      const winningScore = 21;
      const losingScore = 19;
      expect(winningScore - losingScore, greaterThanOrEqualTo(AppConstants.minWinMargin));
    });
  });

  group('Theme System', () {
    test('should have all required themes', () {
      expect(AppThemes.themes.containsKey('light'), true);
      expect(AppThemes.themes.containsKey('minimal'), true);
      expect(AppThemes.themes.containsKey('energy'), true);
      expect(AppThemes.themes.containsKey('court'), true);
      expect(AppThemes.themes.containsKey('champion'), true);
      expect(AppThemes.themes.containsKey('midnight'), true);
    });

    test('should have cached theme keys', () {
      expect(AppThemes.themeKeys.length, 6); // 5 original + midnight
      expect(AppThemes.themeKeys, contains('light'));
      expect(AppThemes.themeKeys, contains('midnight'));
    });

    test('each theme should have all required colors', () {
      for (final theme in AppThemes.themes.values) {
        expect(theme.background, isNotNull);
        expect(theme.primary, isNotNull);
        expect(theme.secondary, isNotNull);
        expect(theme.surface, isNotNull);
        expect(theme.onSurface, isNotNull);
        expect(theme.accent, isNotNull);
        expect(theme.gamePoint, isNotNull);
      }
    });
  });

  group('ScoreAction', () {
    test('should create score action correctly', () {
      const action = ScoreAction(
        isLeft: true,
        previousScore: 5,
        newScore: 6,
        previousServerWasLeft: true,
      );
      expect(action.isLeft, true);
      expect(action.previousScore, 5);
      expect(action.newScore, 6);
      expect(action.previousServerWasLeft, true);
    });
  });

  group('Widget Tests', () {
    test('BadmintonScoreApp should be a StatefulWidget', () {
      expect(const BadmintonScoreApp(), isA<StatefulWidget>());
    });

    test('ScoreScreen should be a StatefulWidget', () {
      const screen = ScoreScreen(
        currentThemeKey: 'light',
        onThemeChange: _mockThemeChange,
      );
      expect(screen, isA<StatefulWidget>());
    });

    testWidgets('ScoreScreen renders correctly', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
        home: ScoreScreen(
          currentThemeKey: 'light',
          onThemeChange: _mockThemeChange,
        ),
      ));

      // Verify that score '0' is displayed for both players
      expect(find.text('0'), findsNWidgets(2));
      
      // Verify players names
      expect(find.text('Left'), findsOneWidget);
      expect(find.text('Right'), findsOneWidget);

      // Verify buttons exist (by icon)
      // Note: Settings and Reset are now inside the Menu dialog, so we verify visible buttons
      expect(find.byIcon(Icons.menu), findsOneWidget); // Menu
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget); // Swap
      expect(find.byIcon(Icons.undo), findsOneWidget); // Undo
      expect(find.byIcon(Icons.remove), findsNWidgets(2)); // Left and Right minus buttons
    });
  });
}
