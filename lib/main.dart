import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:segment_display/segment_display.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'game/game_controller.dart';
import 'theme/app_theme.dart';
import 'widgets/settings_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
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
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController()..load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              _controller.resetScores();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        leftName: _controller.leftPlayerName,
        rightName: _controller.rightPlayerName,
        leftColor: _controller.leftAccent,
        rightColor: _controller.rightAccent,
        scoreSize: _controller.scoreSize,
        soundEnabled: _controller.soundEnabled,
        onSoundChanged: _controller.setSoundEnabled,
        onSave: ({
          required String leftName,
          required String rightName,
          required Color leftColor,
          required Color rightColor,
          required double scoreSize,
        }) {
          _controller.applySettings(
            leftName: leftName,
            rightName: rightName,
            leftColor: leftColor,
            rightColor: rightColor,
            scoreSize: scoreSize,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final palette = AppTheme.current;
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
                          playerName: _controller.leftPlayerName,
                          score: _controller.leftScore,
                          accent: _controller.leftAccent,
                          displaySize: _controller.scoreSize,
                          onTap: () => _controller.increment(true),
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
                          playerName: _controller.rightPlayerName,
                          score: _controller.rightScore,
                          accent: _controller.rightAccent,
                          displaySize: _controller.scoreSize,
                          onTap: () => _controller.increment(false),
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
                        onTap: () => _controller.decrement(true),
                      ),
                    ),
                    _ControlButton(
                      icon: LucideIcons.undo2,
                      label: 'Undo last change',
                      palette: palette,
                      enabled: _controller.canUndo,
                      onTap: _controller.undo,
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
                        onTap: () => _controller.decrement(false),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ScorePanel extends StatelessWidget {
  final String playerName;
  final int score;
  final Color accent;
  final double displaySize;
  final VoidCallback onTap;

  const _ScorePanel({
    super.key,
    required this.playerName,
    required this.score,
    required this.accent,
    required this.displaySize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$playerName, score $score',
      onTap: onTap,
      child: GestureDetector(
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
  final bool enabled;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.palette,
    this.highlighted = false,
    this.expanded = false,
    this.enabled = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = highlighted ? palette.accent : palette.textSecondary;
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: enabled ? onTap : null,
            child: Container(
              width: expanded ? double.infinity : null,
              alignment: Alignment.center,
              // Same vertical padding for every button so the whole
              // control row shares one full tap height.
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 24,
              ),
              child: Icon(icon, size: expanded ? 36 : 28, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
