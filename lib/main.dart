import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:segment_display/segment_display.dart';

import 'audio/beep.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const MyApp());
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
    try {
      await _player.stop();
      await _player.play(source);
    } catch (e) {
      debugPrint('Audio playback failed: $e');
    }
  }

  void _increment(bool isLeft) {
    setState(() {
      if (isLeft) {
        leftScore++;
      } else {
        rightScore++;
      }
    });
    _playSource(_incrementSource);
  }

  void _decrement(bool isLeft) {
    final currentScore = isLeft ? leftScore : rightScore;
    if (currentScore <= 0) {
      return;
    }
    setState(() {
      if (isLeft) {
        leftScore--;
      } else {
        rightScore--;
      }
    });
    _playSource(_decrementSource);
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Settings'),
        content: Text('TODO: settings content'),
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
                      score: leftScore,
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
                      score: rightScore,
                      palette: palette,
                      onTap: () => _increment(false),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: palette.divider),
            // Row 2: minus - settings - minus.
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
                  icon: LucideIcons.settings,
                  label: 'Open settings',
                  palette: palette,
                  highlighted: true,
                  onTap: _openSettings,
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
  final int score;
  final AppPalette palette;
  final VoidCallback onTap;

  const _ScorePanel({
    super.key,
    required this.score,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(
            fit: BoxFit.contain,
            child: SevenSegmentDisplay(
              value: '$score',
              size: 14,
              characterSpacing: 12,
              backgroundColor: Colors.transparent,
              segmentStyle: DefaultSegmentStyle(
                enabledColor: palette.accent,
                disabledColor: Colors.transparent,
              ),
            ),
          ),
        ),
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
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: expanded ? 24 : 16,
            ),
            child: Icon(icon, size: expanded ? 36 : 28, color: color),
          ),
        ),
      ),
    );
  }
}
