import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'models/app_constants.dart';
import 'models/match_result.dart';
import 'models/score_action.dart';
import 'theme/theme.dart';
import 'widgets/match_history_dialog.dart';
import 'widgets/rename_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/win_dialog.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable();
    runApp(const BadmintonScoreApp());
  });
}

class BadmintonScoreApp extends StatefulWidget {
  const BadmintonScoreApp({super.key});

  @override
  State<BadmintonScoreApp> createState() => _BadmintonScoreAppState();
}

class _BadmintonScoreAppState extends State<BadmintonScoreApp> {
  String currentThemeKey = AppThemes.themeKeys.last;
  bool _isLoading = true;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await _getPrefs();
      final savedTheme = prefs.getString('theme') ?? 'midnight';
      setState(() {
        currentThemeKey =
            AppThemes.themes.containsKey(savedTheme) ? savedTheme : 'midnight';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Theme loading failed: $e');
      setState(() {
        currentThemeKey = 'midnight';
        _isLoading = false;
      });
    }
  }

  Future<void> changeTheme(String themeName) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString('theme', themeName);
      setState(() {
        currentThemeKey = themeName;
      });
    } catch (e) {
      debugPrint('Theme save failed: $e');
      setState(() {
        currentThemeKey = themeName;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Color(0xFF121212),
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Poppins'),
      home: ScoreScreen(
        currentThemeKey: currentThemeKey,
        onThemeChange: changeTheme,
      ),
    );
  }
}

class ScoreScreen extends StatefulWidget {
  final String currentThemeKey;
  final Function(String) onThemeChange;

  const ScoreScreen({
    super.key,
    required this.currentThemeKey,
    required this.onThemeChange,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen> {
  int leftScore = 0;
  int rightScore = 0;
  int leftGames = 0;
  int rightGames = 0;
  bool isLeftServing = true;
  int targetScore = AppConstants.defaultTargetScore;
  String leftPlayerName = 'Left';
  String rightPlayerName = 'Right';

  bool soundEnabled = true;

  List<MatchResult> _matchHistory = [];
  final List<ScoreAction> _undoHistory = [];

  late AudioPlayer _player;
  late final Source _beepSource;

  SharedPreferences? _prefs;

  ThemeColors get theme => AppThemes.themes[widget.currentThemeKey]!;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _beepSource = AssetSource('beep.mp3');
    _preloadAudio();
    _loadPreferences();
    _loadMatchHistory();
  }

  Future<void> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _preloadAudio() async {
    try {
      await _player.setSource(_beepSource);
    } catch (e) {
      debugPrint('Audio preload failed: $e');
    }
  }

  Future<void> _loadPreferences() async {
    await _getPrefs();
    if (_prefs == null) {
      return;
    }

    try {
      setState(() {
        soundEnabled = _prefs?.getBool('soundEnabled') ?? true;
        targetScore =
            _prefs?.getInt('targetScore') ?? AppConstants.defaultTargetScore;
        leftPlayerName = _prefs?.getString('leftPlayerName') ?? 'Left';
        rightPlayerName = _prefs?.getString('rightPlayerName') ?? 'Right';
      });
    } catch (e) {
      debugPrint('Preferences loading failed: $e');
    }
  }

  Future<void> _savePreferences() async {
    if (_prefs == null) {
      return;
    }

    try {
      await _prefs!.setBool('soundEnabled', soundEnabled);
      await _prefs!.setInt('targetScore', targetScore);
      await _prefs!.setString('leftPlayerName', leftPlayerName);
      await _prefs!.setString('rightPlayerName', rightPlayerName);
    } catch (e) {
      debugPrint('Preferences save failed: $e');
    }
  }

  Future<void> _loadMatchHistory() async {
    await _getPrefs();
    if (_prefs == null) {
      return;
    }

    try {
      final json = _prefs?.getString('matchHistory');
      if (json != null && json.isNotEmpty) {
        setState(() {
          _matchHistory = MatchResult.decodeList(json);
        });
      }
    } catch (e) {
      debugPrint('Match history loading failed: $e');
    }
  }

  Future<void> _saveMatchHistory() async {
    if (_prefs == null) {
      return;
    }

    try {
      final json = MatchResult.encodeList(_matchHistory);
      await _prefs!.setString('matchHistory', json);
    } catch (e) {
      debugPrint('Match history save failed: $e');
    }
  }

  void _addMatchResult(bool isLeftWinner) {
    final result = MatchResult(
      date: DateTime.now(),
      leftScore: leftScore,
      rightScore: rightScore,
      leftPlayerName: leftPlayerName,
      rightPlayerName: rightPlayerName,
      winner: isLeftWinner ? leftPlayerName : rightPlayerName,
    );

    setState(() {
      _matchHistory.add(result);
      if (_matchHistory.length > 50) {
        _matchHistory = _matchHistory.sublist(_matchHistory.length - 50);
      }
    });

    _saveMatchHistory();
  }

  void _clearMatchHistory() {
    setState(() {
      _matchHistory.clear();
    });
    _saveMatchHistory();
  }

  Future<void> _playPointCue() async {
    if (!soundEnabled) {
      return;
    }

    try {
      await _player.stop();
      await _player.play(_beepSource);
    } catch (e) {
      debugPrint('Audio playback failed: $e');
    }
  }

  void _incrementScore(bool isLeft) {
    final previousScore = isLeft ? leftScore : rightScore;
    final previousServerWasLeft = isLeftServing;

    setState(() {
      if (isLeft) {
        leftScore++;
      } else {
        rightScore++;
      }

      isLeftServing = isLeft;

      _undoHistory.add(
        ScoreAction(
          isLeft: isLeft,
          previousScore: previousScore,
          newScore: isLeft ? leftScore : rightScore,
          previousServerWasLeft: previousServerWasLeft,
        ),
      );

      if (_undoHistory.length > AppConstants.maxUndoHistory) {
        _undoHistory.removeAt(0);
      }
    });

    _playPointCue();
    HapticFeedback.selectionClick();

    if (_checkWin(leftScore, rightScore)) {
      _showWinCelebration(true);
    } else if (_checkWin(rightScore, leftScore)) {
      _showWinCelebration(false);
    }
  }

  void _decrementScore(bool isLeft) {
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

    HapticFeedback.lightImpact();
  }

  bool _checkWin(int score, int opponentScore) {
    final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;
    if (score >= dynamicMaxScore) {
      return true;
    }

    if (score >= targetScore &&
        score - opponentScore >= AppConstants.minWinMargin) {
      return true;
    }

    return false;
  }

  void _showWinCelebration(bool isLeftWinner) {
    final winner = isLeftWinner ? leftPlayerName : rightPlayerName;
    HapticFeedback.heavyImpact();
    _addMatchResult(isLeftWinner);

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => WinDialog(
        winnerName: winner,
        leftScore: leftScore,
        rightScore: rightScore,
        targetScore: targetScore,
        theme: theme,
        onNewGame: () {
          setState(() {
            if (isLeftWinner) {
              leftGames++;
            } else {
              rightGames++;
            }

            leftScore = 0;
            rightScore = 0;
            _undoHistory.clear();
            isLeftServing = true;
          });
          Navigator.of(context).pop();
        },
        onContinue: () {
          Navigator.of(context).pop();
        },
      ),
    );
  }

  void _undo() {
    if (_undoHistory.isEmpty) {
      return;
    }

    final lastAction = _undoHistory.removeLast();
    setState(() {
      if (lastAction.isLeft) {
        leftScore = lastAction.previousScore;
      } else {
        rightScore = lastAction.previousScore;
      }
      isLeftServing = lastAction.previousServerWasLeft;
    });

    HapticFeedback.lightImpact();
  }

  void _swapSides() {
    setState(() {
      final tempScore = leftScore;
      leftScore = rightScore;
      rightScore = tempScore;

      final tempGames = leftGames;
      leftGames = rightGames;
      rightGames = tempGames;

      final tempName = leftPlayerName;
      leftPlayerName = rightPlayerName;
      rightPlayerName = tempName;

      isLeftServing = !isLeftServing;
    });

    _savePreferences();
    HapticFeedback.mediumImpact();
  }

  void _resetGame() {
    setState(() {
      leftScore = 0;
      rightScore = 0;
      _undoHistory.clear();
      isLeftServing = true;
    });

    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Game reset', style: TextStyle(fontFamily: 'Poppins')),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        theme: theme,
        targetScore: targetScore,
        onTargetScoreChanged: (val) {
          setState(() => targetScore = val);
          _savePreferences();
          Navigator.pop(context);
        },
        soundEnabled: soundEnabled,
        onSoundChanged: (val) {
          setState(() => soundEnabled = val);
          _savePreferences();
        },
      ),
    );
  }

  void _showRenameDialog() {
    showDialog(
      context: context,
      builder: (context) => RenameDialog(
        theme: theme,
        leftName: leftPlayerName,
        rightName: rightPlayerName,
        onSave: (left, right) {
          setState(() {
            leftPlayerName = left;
            rightPlayerName = right;
          });
          _savePreferences();
        },
      ),
    );
  }

  void _showMatchHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => MatchHistoryDialog(
        theme: theme,
        history: _matchHistory,
        onClearHistory: _clearMatchHistory,
      ),
    );
  }

  void _openFromSheet(BuildContext sheetContext, VoidCallback action) {
    Navigator.of(sheetContext).pop();
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (mounted) {
        action();
      }
    });
  }

  void _showMenuSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BottomSheetShell(
          theme: theme,
          title: 'Match Controls',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _SheetActionTile(
                icon: Icons.edit,
                label: 'Rename Players',
                onTap: () => _openFromSheet(sheetContext, _showRenameDialog),
              ),
              _SheetActionTile(
                icon: Icons.palette_outlined,
                label: 'Switch Theme',
                onTap: () => _openFromSheet(sheetContext, _showThemeSelector),
              ),
              _SheetActionTile(
                icon: Icons.history,
                label: 'Match History',
                onTap: () =>
                    _openFromSheet(sheetContext, _showMatchHistoryDialog),
              ),
              _SheetActionTile(
                icon: Icons.settings,
                label: 'Settings',
                onTap: () => _openFromSheet(sheetContext, _showSettings),
              ),
              _SheetActionTile(
                icon: Icons.refresh,
                label: 'Reset Current Game',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _resetGame();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showThemeSelector() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return _BottomSheetShell(
          theme: theme,
          title: 'Select Theme',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: AppThemes.themes.entries.map((entry) {
              return _ThemeTile(
                name: entry.value.name,
                primary: entry.value.primary,
                secondary: entry.value.secondary,
                isSelected: entry.key == widget.currentThemeKey,
                onTap: () {
                  widget.onThemeChange(entry.key);
                  Navigator.of(sheetContext).pop();
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildTopStrip() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COURT CONTROL',
                style: TextStyle(
                  color: theme.textSecondary,
                  fontSize: 12,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$leftPlayerName vs $rightPlayerName',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _MetricChip(label: 'Target', value: '$targetScore'),
        const SizedBox(width: 8),
        _MetricChip(label: 'Games', value: '$leftGames-$rightGames'),
        const SizedBox(width: 12),
        _TopActionButton(
          icon: Icons.palette_outlined,
          tooltip: 'Theme',
          onTap: _showThemeSelector,
        ),
        const SizedBox(width: 6),
        _TopActionButton(
          icon: Icons.settings,
          tooltip: 'Settings',
          onTap: _showSettings,
        ),
        const SizedBox(width: 6),
        _TopActionButton(
          icon: Icons.menu,
          tooltip: 'Menu',
          onTap: _showMenuSheet,
        ),
      ],
    );
  }

  Widget _buildWideLayout(BoxConstraints constraints, bool reducedMotion) {
    final centerWidth =
        (constraints.maxWidth * 0.19).clamp(180.0, 260.0).toDouble();

    return Row(
      children: [
        Expanded(
          child: _PlayerPanel(
            playerName: leftPlayerName,
            score: leftScore,
            isServing: isLeftServing,
            isWinner: _checkWin(leftScore, rightScore),
            accent: theme.primary,
            surface: theme.surface,
            foreground: theme.textPrimary,
            subtext: theme.textSecondary,
            onTap: () => _incrementScore(true),
            onSwipeDown: () => _decrementScore(true),
            onRename: _showRenameDialog,
            reducedMotion: reducedMotion,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: centerWidth,
          child: _buildCenterConsole(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PlayerPanel(
            playerName: rightPlayerName,
            score: rightScore,
            isServing: !isLeftServing,
            isWinner: _checkWin(rightScore, leftScore),
            accent: theme.secondary,
            surface: theme.surface,
            foreground: theme.textPrimary,
            subtext: theme.textSecondary,
            onTap: () => _incrementScore(false),
            onSwipeDown: () => _decrementScore(false),
            onRename: _showRenameDialog,
            reducedMotion: reducedMotion,
          ),
        ),
      ],
    );
  }

  Widget _buildCompactLayout(bool reducedMotion) {
    return Column(
      children: [
        Expanded(
          child: _PlayerPanel(
            playerName: leftPlayerName,
            score: leftScore,
            isServing: isLeftServing,
            isWinner: _checkWin(leftScore, rightScore),
            accent: theme.primary,
            surface: theme.surface,
            foreground: theme.textPrimary,
            subtext: theme.textSecondary,
            onTap: () => _incrementScore(true),
            onSwipeDown: () => _decrementScore(true),
            onRename: _showRenameDialog,
            reducedMotion: reducedMotion,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(height: 96, child: _buildCenterConsole()),
        const SizedBox(height: 10),
        Expanded(
          child: _PlayerPanel(
            playerName: rightPlayerName,
            score: rightScore,
            isServing: !isLeftServing,
            isWinner: _checkWin(rightScore, leftScore),
            accent: theme.secondary,
            surface: theme.surface,
            foreground: theme.textPrimary,
            subtext: theme.textSecondary,
            onTap: () => _incrementScore(false),
            onSwipeDown: () => _decrementScore(false),
            onRename: _showRenameDialog,
            reducedMotion: reducedMotion,
          ),
        ),
      ],
    );
  }

  Widget _buildCenterConsole() {
    final canUndo = _undoHistory.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 180;
        final direction = compact ? Axis.horizontal : Axis.vertical;

        return Container(
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.glassBorder, width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Flex(
            direction: direction,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _CommandButton(
                icon: Icons.undo,
                label: 'Undo',
                enabled: canUndo,
                onTap: _undo,
                color: theme.textPrimary,
              ),
              _CommandButton(
                icon: Icons.swap_horiz,
                label: 'Swap',
                onTap: _swapSides,
                color: theme.textPrimary,
              ),
              _CommandButton(
                icon: Icons.restart_alt,
                label: 'Reset',
                onTap: _resetGame,
                color: theme.textPrimary,
              ),
              _CommandButton(
                icon: Icons.history,
                label: 'History',
                onTap: _showMatchHistoryDialog,
                color: theme.textPrimary,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final reducedMotion =
        mediaQuery.disableAnimations || mediaQuery.accessibleNavigation;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: theme.backgroundGradient,
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              left: -50,
              child: _GlowOrb(
                size: 260,
                color: theme.primary.withValues(alpha: 0.16),
              ),
            ),
            Positioned(
              bottom: -120,
              right: -80,
              child: _GlowOrb(
                size: 320,
                color: theme.secondary.withValues(alpha: 0.14),
              ),
            ),
            Positioned(
              top: 110,
              right: 140,
              child: _GlowOrb(
                size: 120,
                color: theme.gamePoint.withValues(alpha: 0.08),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isCompact = constraints.maxWidth < 900;

                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: [
                        _buildTopStrip(),
                        const SizedBox(height: 12),
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: reducedMotion
                                ? Duration.zero
                                : const Duration(milliseconds: 260),
                            child: isCompact
                                ? _buildCompactLayout(reducedMotion)
                                : _buildWideLayout(constraints, reducedMotion),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  final String playerName;
  final int score;
  final bool isServing;
  final bool isWinner;
  final Color accent;
  final Color surface;
  final Color foreground;
  final Color subtext;
  final VoidCallback onTap;
  final VoidCallback onSwipeDown;
  final VoidCallback onRename;
  final bool reducedMotion;

  const _PlayerPanel({
    required this.playerName,
    required this.score,
    required this.isServing,
    required this.isWinner,
    required this.accent,
    required this.surface,
    required this.foreground,
    required this.subtext,
    required this.onTap,
    required this.onSwipeDown,
    required this.onRename,
    required this.reducedMotion,
  });

  @override
  Widget build(BuildContext context) {
    final duration = reducedMotion
        ? Duration.zero
        : const Duration(milliseconds: 220);

    return Semantics(
      button: true,
      label: '$playerName score $score ${isServing ? 'serving' : ''}',
      hint: 'Double tap to add a point. Swipe down to subtract a point.',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          if (velocity > AppConstants.minSwipeVelocity) {
            onSwipeDown();
          }
        },
        child: AnimatedContainer(
          duration: duration,
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: surface.withValues(alpha: isWinner ? 0.54 : 0.34),
            border: Border.all(
              color: isServing ? accent : foreground.withValues(alpha: 0.18),
              width: isServing ? 3 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: isServing ? 0.26 : 0.1),
                blurRadius: isServing ? 28 : 16,
                spreadRadius: isServing ? 2 : 0,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            playerName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: foreground,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        if (isServing) ...[
                          Icon(Icons.sports_tennis, color: accent, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Serve',
                            style: TextStyle(
                              color: accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          iconSize: 18,
                          color: subtext,
                          tooltip: 'Rename players',
                          onPressed: onRename,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: AnimatedSwitcher(
                            duration: duration,
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: ScaleTransition(
                                  scale: Tween<double>(begin: 0.9, end: 1.0)
                                      .animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              '$score',
                              key: ValueKey<int>(score),
                              style: TextStyle(
                                color: isWinner ? accent : foreground,
                                fontWeight: FontWeight.w900,
                                fontSize: 180,
                                height: 0.92,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      'Tap +1   |   Swipe down -1',
                      style: TextStyle(
                        color: subtext,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CommandButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final Color color;

  const _CommandButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: enabled ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.1),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _TopActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _TopActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Material(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, size: 20),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}

class _BottomSheetShell extends StatelessWidget {
  final ThemeColors theme;
  final String title;
  final Widget child;

  const _BottomSheetShell({
    required this.theme,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          decoration: BoxDecoration(
            color: theme.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: theme.glassBorder, width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.textSecondary.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SheetActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeTile extends StatelessWidget {
  final String name;
  final Color primary;
  final Color secondary;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeTile({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Theme $name',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: 170,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primary : Colors.white24,
              width: isSelected ? 2.4 : 1,
            ),
            color: Colors.white.withValues(alpha: 0.04),
          ),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: secondary,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: primary, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
