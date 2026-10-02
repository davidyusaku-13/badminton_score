import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../audio/beep.dart';
import '../theme/app_theme.dart';

/// Default settings values, shared with the settings dialog.
const String kDefaultLeftName = 'Player 1';
const String kDefaultRightName = 'Player 2';
const double kDefaultScoreSize = 14;
const bool kDefaultSoundEnabled = true;

/// Owns all score screen state.
///
/// Session state (scores, undo history) lives only in memory.
/// Display settings (names, colors, size, sound) are persisted.
class GameController extends ChangeNotifier {
  int leftScore = 0;
  int rightScore = 0;
  String leftPlayerName = kDefaultLeftName;
  String rightPlayerName = kDefaultRightName;
  Color leftAccent = AppTheme.current.accent;
  Color rightAccent = AppTheme.current.accentSecondary;
  double scoreSize = kDefaultScoreSize;
  bool soundEnabled = kDefaultSoundEnabled;

  /// Previous (left, right) scores for undo. Capped to avoid unbounded growth.
  final List<(int, int)> _history = [];

  late final AudioPlayer _player;
  late final Source _incrementSource;
  late final Source _decrementSource;

  GameController() {
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _incrementSource = BytesSource(generateBeepWav(frequency: 880));
    _decrementSource = BytesSource(generateBeepWav(frequency: 587));
  }

  bool get canUndo => _history.isNotEmpty;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      leftPlayerName = prefs.getString('leftName') ?? kDefaultLeftName;
      rightPlayerName = prefs.getString('rightName') ?? kDefaultRightName;
      leftAccent = Color(
        prefs.getInt('leftColor') ?? AppTheme.current.accent.toARGB32(),
      );
      rightAccent = Color(
        prefs.getInt('rightColor') ??
            AppTheme.current.accentSecondary.toARGB32(),
      );
      scoreSize = prefs.getDouble('scoreSize') ?? kDefaultScoreSize;
      soundEnabled = prefs.getBool('soundEnabled') ?? kDefaultSoundEnabled;
      notifyListeners();
    } catch (e) {
      debugPrint('Settings load failed: $e');
    }
  }

  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('leftName', leftPlayerName);
      await prefs.setString('rightName', rightPlayerName);
      await prefs.setInt('leftColor', leftAccent.toARGB32());
      await prefs.setInt('rightColor', rightAccent.toARGB32());
      await prefs.setDouble('scoreSize', scoreSize);
      await prefs.setBool('soundEnabled', soundEnabled);
    } catch (e) {
      debugPrint('Settings save failed: $e');
    }
  }

  void _pushHistory() {
    _history.add((leftScore, rightScore));
    if (_history.length > 100) {
      _history.removeAt(0);
    }
  }

  Future<void> _playSource(Source source) async {
    if (!soundEnabled) {
      return;
    }
    try {
      await _player.stop();
      await _player.play(source);
    } catch (e) {
      debugPrint('Audio playback failed: $e');
    }
  }

  void increment(bool isLeft) {
    _pushHistory();
    if (isLeft) {
      leftScore++;
    } else {
      rightScore++;
    }
    HapticFeedback.selectionClick();
    notifyListeners();
    _playSource(_incrementSource);
  }

  void decrement(bool isLeft) {
    final currentScore = isLeft ? leftScore : rightScore;
    if (currentScore <= 0) {
      return;
    }
    _pushHistory();
    if (isLeft) {
      leftScore--;
    } else {
      rightScore--;
    }
    HapticFeedback.lightImpact();
    notifyListeners();
    _playSource(_decrementSource);
  }

  void undo() {
    if (_history.isEmpty) {
      return;
    }
    final previous = _history.removeLast();
    leftScore = previous.$1;
    rightScore = previous.$2;
    HapticFeedback.lightImpact();
    notifyListeners();
  }

  void resetScores() {
    _pushHistory();
    leftScore = 0;
    rightScore = 0;
    HapticFeedback.mediumImpact();
    notifyListeners();
  }

  void applySettings({
    required String leftName,
    required String rightName,
    required Color leftColor,
    required Color rightColor,
    required double scoreSize,
  }) {
    final trimmedLeft = leftName.trim();
    final trimmedRight = rightName.trim();
    if (trimmedLeft.isNotEmpty) {
      leftPlayerName = trimmedLeft;
    }
    if (trimmedRight.isNotEmpty) {
      rightPlayerName = trimmedRight;
    }
    leftAccent = leftColor;
    rightAccent = rightColor;
    this.scoreSize = scoreSize;
    notifyListeners();
    unawaited(_saveSettings());
  }

  void setSoundEnabled(bool value) {
    soundEnabled = value;
    notifyListeners();
    unawaited(_saveSettings());
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
