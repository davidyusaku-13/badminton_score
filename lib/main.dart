import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'theme/theme.dart';
import 'models/app_constants.dart';
import 'models/score_action.dart';
import 'models/match_result.dart';
import 'widgets/score_card.dart';
import 'widgets/control_button.dart';
import 'widgets/glass_container.dart';
import 'widgets/win_dialog.dart';
import 'widgets/settings_dialog.dart';
import 'widgets/rename_dialog.dart';
import 'widgets/match_history_dialog.dart';

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
  String currentThemeKey = AppThemes.themeKeys.last; // Default to Midnight
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
        currentThemeKey = AppThemes.themes.containsKey(savedTheme) ? savedTheme : 'midnight';
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

class _ScoreScreenState extends State<ScoreScreen> with SingleTickerProviderStateMixin {
  
  // Game State
  int leftScore = 0;
  int rightScore = 0;
  int leftGames = 0;
  int rightGames = 0;
  bool isLeftServing = true;
  int targetScore = AppConstants.defaultTargetScore;
  String leftPlayerName = 'Left';
  String rightPlayerName = 'Right';
  
  // Settings
  bool soundEnabled = true;
  
  // Match History
  List<MatchResult> _matchHistory = [];
  
  // Undo history
  final List<ScoreAction> _undoHistory = [];

  // Audio
  late AudioPlayer _player;
  late final Source _beepSource;
  
  // Cached SharedPreferences
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _beepSource = AssetSource('beep.mp3');
    _preloadAudio();
    _loadPreferences();
    _loadMatchHistory();
  }
  
  ThemeColors get theme => AppThemes.themes[widget.currentThemeKey]!;

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
    if (_prefs == null) return; // Guard against null
    try {
      setState(() {
        soundEnabled = _prefs?.getBool('soundEnabled') ?? true;
        targetScore = _prefs?.getInt('targetScore') ?? AppConstants.defaultTargetScore;
        leftPlayerName = _prefs?.getString('leftPlayerName') ?? 'Left';
        rightPlayerName = _prefs?.getString('rightPlayerName') ?? 'Right';
      });
    } catch (e) {
      debugPrint('Preferences loading failed: $e');
    }
  }

  Future<void> _savePreferences() async {
     if (_prefs == null) return;
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
    if (_prefs == null) return;
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
    if (_prefs == null) return;
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
      // Keep only last 50 matches
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

  Future<void> _beep() async {
    if (soundEnabled) {
      try {
        await _player.stop();
        await _player.play(_beepSource);
      } catch (e) {
        debugPrint('Audio playback failed: $e');
      }
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

      _undoHistory.add(ScoreAction(
        isLeft: isLeft,
        previousScore: previousScore,
        newScore: isLeft ? leftScore : rightScore,
        previousServerWasLeft: previousServerWasLeft,
      ));
      if (_undoHistory.length > AppConstants.maxUndoHistory) {
        _undoHistory.removeAt(0);
      }
    });

    _beep();

    if (_checkWin(leftScore, rightScore)) {
      _showWinCelebration(true);
    } else if (_checkWin(rightScore, leftScore)) {
      _showWinCelebration(false);
    }
  }

  void _decrementScore(bool isLeft) {
     final currentScore = isLeft ? leftScore : rightScore;
    if (currentScore <= 0) return;

    setState(() {
      if (isLeft) {
        leftScore--;
      } else {
        rightScore--;
      }
    });
  }

  bool _checkWin(int score, int opponentScore) {
    final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;
    if (score >= dynamicMaxScore) return true;
    if (score >= targetScore &&
        score - opponentScore >= AppConstants.minWinMargin) {
      return true;
    }
    return false;
  }

  void _showWinCelebration(bool isLeftWinner) {
     final winner = isLeftWinner ? leftPlayerName : rightPlayerName;
    HapticFeedback.heavyImpact();
    
    // Save match result to history
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
        }
      ),
    );
  }

  void _undo() {
    if (_undoHistory.isEmpty) return;

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
     _savePreferences(); // Save name swap
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
        SnackBar(content: const Text("Game Reset", style: TextStyle(fontFamily: 'Poppins')), duration: Duration(seconds: 1),)
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
        ));
  }
  
  void _showRenameDialog() {
      showDialog(
        context: context,
        builder: (context) => RenameDialog(
            theme: theme,
            leftName: leftPlayerName,
            rightName: rightPlayerName,
            onSave: (l, r) {
                setState(() {
                    leftPlayerName = l;
                    rightPlayerName = r;
                });
                _savePreferences();
            }
        )
      );
  }
  
  void _showMenuDialog() {
       showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassContainer(
            borderRadius: BorderRadius.circular(24),
            color: theme.surface,
            opacity: 0.95,
            padding: const EdgeInsets.all(16),
             child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.person, color: theme.textPrimary),
                  title: Text("Players", style: TextStyle(color: theme.textPrimary)),
                  onTap: () { Navigator.pop(context); _showRenameDialog(); }
                ),
                 ListTile(
                  leading: Icon(Icons.refresh, color: theme.textPrimary),
                  title: Text("Reset Game", style: TextStyle(color: theme.textPrimary)),
                  onTap: () { Navigator.pop(context); _resetGame(); }
                ),
                 ListTile(
                  leading: Icon(Icons.palette, color: theme.textPrimary),
                  title: Text("Theme", style: TextStyle(color: theme.textPrimary)),
                  onTap: () { Navigator.pop(context); _showThemeSelector(); }
                ),
                 ListTile(
                  leading: Icon(Icons.history, color: theme.textPrimary),
                  title: Text("History", style: TextStyle(color: theme.textPrimary)),
                  onTap: () { Navigator.pop(context); _showMatchHistoryDialog(); }
                ),
                 ListTile(
                  leading: Icon(Icons.settings, color: theme.textPrimary),
                  title: Text("Settings", style: TextStyle(color: theme.textPrimary)),
                  onTap: () { Navigator.pop(context); _showSettings(); }
                ),
              ],
             ),
          ),
        ),
       );
  }
  
  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: BorderRadius.circular(24),
          color: theme.surface,
          opacity: 0.95,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Select Theme",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ...AppThemes.themes.entries.map((entry) {
                final isSelected = entry.key == widget.currentThemeKey;
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: entry.value.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 20, height: 20,
                        decoration: BoxDecoration(
                          color: entry.value.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    entry.value.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: theme.textPrimary,
                    ),
                  ),
                  trailing: isSelected 
                      ? Icon(Icons.check, color: entry.value.primary)
                      : null,
                  onTap: () {
                    widget.onThemeChange(entry.key);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: theme.backgroundGradient),
        child: SafeArea(
          child: Column(
            children: [
              // TOP: Score Section (75%)
              Expanded(
                flex: AppConstants.scoreSectionFlex,
                child: Row(
                  children: [
                    // Left Player
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ScoreCard(
                          score: leftScore,
                          playerName: leftPlayerName,
                          isServing: isLeftServing,
                          isWinner: _checkWin(leftScore, rightScore),
                          onTap: () => _incrementScore(true),
                          onSwipeDown: () => _decrementScore(true),
                          onNameTap: _showRenameDialog,
                          theme: theme,
                        ),
                      ),
                    ),
                    // Right Player
                    Expanded(
                       child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ScoreCard(
                          score: rightScore,
                          playerName: rightPlayerName,
                          isServing: !isLeftServing,
                          isWinner: _checkWin(rightScore, leftScore),
                          onTap: () => _incrementScore(false),
                          onSwipeDown: () => _decrementScore(false),
                          onNameTap: _showRenameDialog,
                          theme: theme,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // BOTTOM: Control Section (25%)
              Expanded(
                flex: AppConstants.controlSectionFlex,
                 child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                       Expanded(child: ControlButton(icon: Icons.remove, label: "Left -1", onTap: () => _decrementScore(true), theme: theme)),
                       const SizedBox(width: 8),
                       Expanded(child: ControlButton(icon: Icons.undo, label: "Undo", onTap: _undo, theme: theme)),
                       const SizedBox(width: 8),
                       Expanded(child: ControlButton(icon: Icons.menu, label: "Menu", onTap: _showMenuDialog, theme: theme)),
                       const SizedBox(width: 8),
                       Expanded(child: ControlButton(icon: Icons.swap_horiz, label: "Swap", onTap: _swapSides, theme: theme)),
                       const SizedBox(width: 8),
                       Expanded(child: ControlButton(icon: Icons.remove, label: "Right -1", onTap: () => _decrementScore(false), theme: theme)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
