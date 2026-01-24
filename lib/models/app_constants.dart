import 'package:flutter/material.dart';

class AppConstants {
  static const int scoreSectionFlex = 75;
  static const int controlSectionFlex = 25;
  static const double scoreTextSize = 256;
  static const double controlTextSize = 50;
  static const double buttonTextSize = 30;
  static const EdgeInsets gridPadding =
      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0);

  // Badminton rules
  static const int minTargetScore = 5;
  static const int defaultTargetScore = 21;
  static const int defaultMatchGames = 3; // Best of 3
  static const int maxScoreOffset = 9; // maxScore = targetScore + 9
  static const int minWinMargin = 2;
  static const List<int> targetScoreOptions = [11, 15, 21, 30];

  // Undo history limit
  static const int maxUndoHistory = 10;

  // Gesture thresholds
  static const double minSwipeVelocity = 500;

  // UI thresholds
  static const int highScoreThreshold = 10;
  static const double controlButtonHeight = 56;
}
