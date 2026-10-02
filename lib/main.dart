import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:segment_display/segment_display.dart';

import 'audio/beep.dart';
import 'theme/app_theme.dart';
import 'widgets/settings_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData(AppTheme.current),
      home: const ScoreScreen(),
    );
  }
}

class ScoreScreen extends StatefulWidget {
  const ScoreScreen({super.key});

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
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

  AppPalette get palette => AppTheme.current;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _incrementSource = BytesSource(generateBeepWav(frequency: 880));
    _decrementSource = BytesSource(generateBeepWav(frequency: 587));
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

  void _pushHistory() {
    _history.add((leftScore, rightScore));
    if (_history.length > 100) {
      _history.removeAt(0);
    }
  }

  void _increment(bool isLeft) {
    _pushHistory();
    setState(() {
      if (isLeft) {
        leftScore++;
      } else {
        rightScore++;
      }
    });
    HapticFeedback.selectionClick();
    _playSource(_incrementSource);
  }

  void _decrement(bool isLeft) {
    final currentScore = isLeft ? leftScore : rightScore;
    if (currentScore <= 0) {
      return;
    }
    _pushHistory();
    setState(() {
      if (isLeft) {
        leftScore--;
      } else {
        rightScore--;
      }
    });
    HapticFeedback.lightImpact();
    _playSource(_decrementSource);
  }

  void _undo() {
    if (_history.isEmpty) {
      return;
    }
    final previous = _history.removeLast();
    setState(() {
      leftScore = previous.$1;
      rightScore = previous.$2;
    });
    HapticFeedback.lightImpact();
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset game?'),
        content: const Text('Both scores will return to 0.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _reset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _reset() {
    _pushHistory();
    setState(() {
      leftScore = 0;
      rightScore = 0;
    });
    HapticFeedback.mediumImpact();
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        leftName: leftPlayerName,
        rightName: rightPlayerName,
        leftColor: leftAccent,
        rightColor: rightAccent,
        scoreSize: scoreSize,
        soundEnabled: soundEnabled,
        onSoundChanged: (value) => setState(() => soundEnabled = value),
        onSave: ({
          required String leftName,
          required String rightName,
          required Color leftColor,
          required Color rightColor,
          required double scoreSize,
        }) {
          setState(() {
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
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Row 1: two score columns.
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: _ScorePanel(
                      key: const Key('leftScorePanel'),
                      playerName: leftPlayerName,
                      score: leftScore,
                      accent: leftAccent,
                      displaySize: scoreSize,
                      palette: palette,
                      onTap: () => _increment(true),
                    ),
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: palette.divider,
                  ),
                  Expanded(
                    child: _ScorePanel(
                      key: const Key('rightScorePanel'),
                      playerName: rightPlayerName,
                      score: rightScore,
                      accent: rightAccent,
                      displaySize: scoreSize,
                      palette: palette,
                      onTap: () => _increment(false),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: palette.divider),
            // Row 2: minus - undo - settings - reset - minus.
            // Minus buttons expand to fill the row for a bigger tap target.
            Row(
              children: [
                Expanded(
                  child: _ControlButton(
                    icon: LucideIcons.minus,
                    label: 'Decrease left score',
                    palette: palette,
                    expanded: true,
                    onTap: () => _decrement(true),
                  ),
                ),
                _ControlButton(
                  icon: LucideIcons.undo2,
                  label: 'Undo last change',
                  palette: palette,
                  onTap: _undo,
                ),
                _ControlButton(
                  icon: LucideIcons.settings,
                  label: 'Open settings',
                  palette: palette,
                  highlighted: true,
                  onTap: _openSettings,
                ),
                _ControlButton(
                  icon: LucideIcons.rotateCcw,
                  label: 'Reset game',
                  palette: palette,
                  onTap: _confirmReset,
                ),
                Expanded(
                  child: _ControlButton(
                    icon: LucideIcons.minus,
                    label: 'Decrease right score',
                    palette: palette,
                    expanded: true,
                    onTap: () => _decrement(false),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePanel extends StatelessWidget {
  final String playerName;
  final int score;
  final Color accent;
  final double displaySize;
  final AppPalette palette;
  final VoidCallback onTap;

  const _ScorePanel({
    super.key,
    required this.playerName,
    required this.score,
    required this.accent,
    required this.displaySize,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Text(
              playerName.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: accent,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: SevenSegmentDisplay(
                    value: '$score',
                    size: displaySize,
                    characterSpacing: 12,
                    backgroundColor: Colors.transparent,
                    segmentStyle: DefaultSegmentStyle(
                      enabledColor: accent,
                      disabledColor: Colors.transparent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final AppPalette palette;
  final bool highlighted;
  final bool expanded;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.palette,
    this.highlighted = false,
    this.expanded = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? palette.accent : palette.textSecondary;
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: expanded ? double.infinity : null,
            alignment: Alignment.center,
            // Same vertical padding for every button so the whole
            // control row shares one full tap height.
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
            child: Icon(icon, size: expanded ? 36 : 28, color: color),
          ),
        ),
      ),
    );
  }
}
