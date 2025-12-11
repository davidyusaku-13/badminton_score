import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Constants
class AppConstants {
  static const int scoreSectionFlex = 75;
  static const int controlSectionFlex = 25;
  static const double scoreTextSize = 256;
  static const double controlTextSize = 50;
  static const double buttonTextSize = 30;
  static const EdgeInsets gridPadding =
      EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);

  // Badminton rules
  static const int minTargetScore = 5;
  static const int defaultTargetScore = 21;
  static const int maxScoreOffset = 9; // maxScore = targetScore + 9
  static const int minWinMargin = 2;

  // Undo history limit
  static const int maxUndoHistory = 10;
}

class ThemeKeys {
  static const String light = 'light';
  static const String minimal = 'minimal';
  static const String energy = 'energy';
  static const String court = 'court';
  static const String champion = 'champion';
  static const String defaultTheme = light;
}

class ThemeColors {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color accent;
  final Color gamePoint;

  const ThemeColors({
    required this.name,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.accent,
    required this.gamePoint,
  });
}

class AppThemes {
  static const Map<String, ThemeColors> themes = {
    'light': ThemeColors(
      name: 'Light',
      background: Color(0xFFFAFAFA),
      primary: Color(0xFFFF8A50),
      secondary: Color(0xFFFFB74D),
      surface: Color(0xFFE0E0E0),
      onSurface: Color(0xFF212121),
      accent: Color(0xFFFF6D00),
      gamePoint: Color(0xFFFFD700),
    ),
    'minimal': ThemeColors(
      name: 'Minimal',
      background: Color(0xFFFFFFFF),
      primary: Color(0xFF757575),
      secondary: Color(0xFF9E9E9E),
      surface: Color(0xFFF5F5F5),
      onSurface: Color(0xFF212121),
      accent: Color(0xFF616161),
      gamePoint: Color(0xFFFFC107),
    ),
    'energy': ThemeColors(
      name: 'Energy',
      background: Color(0xFFFFF8E1),
      primary: Color(0xFFFF5722),
      secondary: Color(0xFFFF9800),
      surface: Color(0xFFFFECB3),
      onSurface: Color(0xFF212121),
      accent: Color(0xFFE64A19),
      gamePoint: Color(0xFFFFD600),
    ),
    'court': ThemeColors(
      name: 'Court',
      background: Color(0xFFE8F5E9),
      primary: Color(0xFF4CAF50),
      secondary: Color(0xFF8BC34A),
      surface: Color(0xFFC8E6C9),
      onSurface: Color(0xFF1B5E20),
      accent: Color(0xFF388E3C),
      gamePoint: Color(0xFFFFEB3B),
    ),
    'champion': ThemeColors(
      name: 'Champion',
      background: Color(0xFFFCE4EC),
      primary: Color(0xFFE91E63),
      secondary: Color(0xFFFF5722),
      surface: Color(0xFFF8BBD9),
      onSurface: Color(0xFF880E4F),
      accent: Color(0xFFC2185B),
      gamePoint: Color(0xFFFFD700),
    ),
  };

  // Cached theme keys list for performance
  static final List<String> themeKeys = themes.keys.toList();
}

// Score action for undo functionality
class ScoreAction {
  final bool isLeft;
  final int previousScore;
  final int newScore;
  final bool previousServerWasLeft;

  const ScoreAction({
    required this.isLeft,
    required this.previousScore,
    required this.newScore,
    required this.previousServerWasLeft,
  });
}

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
  String currentTheme = ThemeKeys.defaultTheme;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('theme') ?? ThemeKeys.defaultTheme;
    setState(() {
      currentTheme = savedTheme;
      _isLoading = false;
    });
  }

  Future<void> changeTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', themeName);
    setState(() {
      currentTheme = themeName;
    });
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
      home: ScoreScreen(
        currentTheme: currentTheme,
        onThemeChange: changeTheme,
      ),
    );
  }
}

class ScoreScreen extends StatefulWidget {
  final String currentTheme;
  final Function(String) onThemeChange;

  const ScoreScreen({
    super.key,
    required this.currentTheme,
    required this.onThemeChange,
  });

  @override
  State<ScoreScreen> createState() => _ScoreScreenState();
}

class _ScoreScreenState extends State<ScoreScreen>
    with SingleTickerProviderStateMixin {
  int leftScore = 0;
  int rightScore = 0;
  int leftGames = 0;
  int rightGames = 0;
  bool soundEnabled = true;
  bool isLeftServing = true;
  int totalPoints = 0;
  int targetScore = AppConstants.defaultTargetScore;

  // Undo history
  final List<ScoreAction> _undoHistory = [];

  // Animation controllers
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isLeftScaling = false;
  bool _isRightScaling = false;

  late AudioPlayer _player;
  late final Source _beepSource;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _beepSource = AssetSource('beep.mp3');
    _preloadAudio();
    _loadPreferences();

    // Setup scale animation
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  Future<void> _preloadAudio() async {
    // Preload the audio source to reduce first-play latency
    await _player.setSource(_beepSource);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      soundEnabled = prefs.getBool('soundEnabled') ?? true;
      targetScore = prefs.getInt('targetScore') ?? AppConstants.defaultTargetScore;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', soundEnabled);
    await prefs.setInt('targetScore', targetScore);
  }

  Future<void> _beep() async {
    if (soundEnabled) {
      await _player.stop();
      await _player.play(_beepSource);
    }
  }

  Future<void> _stopSound() async {
    await _player.stop();
  }

  void _safeAction(VoidCallback action) {
    _stopSound();
    action();
  }

  void _updateServingIndicator(bool scoringTeamIsLeft) {
    // Badminton serving rules: the team that scores the point serves next
    isLeftServing = scoringTeamIsLeft;
  }

  void _resetServingIndicator() {
    // Reset to left serving at start of game
    isLeftServing = true;
  }

  bool _checkWin(int score, int opponentScore) {
    final dynamicMaxScore = targetScore + AppConstants.maxScoreOffset;
    // Win at maxScore regardless of margin (sudden death cap)
    if (score >= dynamicMaxScore) return true;
    // Win at targetScore with required margin
    if (score >= targetScore &&
        score - opponentScore >= AppConstants.minWinMargin) {
      return true;
    }
    return false;
  }

  bool _isGamePoint(int score, int opponentScore) {
    // Check if scoring one more point would win
    return _checkWin(score + 1, opponentScore);
  }

  void _showWinCelebration(bool isLeftWinner) {
    final winner = isLeftWinner ? "Left" : "Right";
    HapticFeedback.heavyImpact();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            "Game Won!",
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.amber,
              fontSize: 28,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$winner Player Wins!",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white,
                  fontSize: 24,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "First to $targetScore",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white54,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Text(
                "$leftScore - $rightScore",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.white70,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text("Continue Match",
                  style: TextStyle(fontFamily: 'Poppins', color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("New Game",
                  style:
                      TextStyle(fontFamily: 'Poppins', color: Colors.amber)),
              onPressed: () {
                // Record game win
                setState(() {
                  if (isLeftWinner) {
                    leftGames++;
                  } else {
                    rightGames++;
                  }
                  leftScore = 0;
                  rightScore = 0;
                  totalPoints = 0;
                  _undoHistory.clear();
                  _resetServingIndicator();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      totalPoints++;
      _updateServingIndicator(isLeft);

      // Add to undo history
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

    // Check for win
    if (_checkWin(leftScore, rightScore)) {
      _showWinCelebration(true);
    } else if (_checkWin(rightScore, leftScore)) {
      _showWinCelebration(false);
    }
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
      totalPoints--;
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

      isLeftServing = !isLeftServing;
    });
    HapticFeedback.mediumImpact();
  }

  void _quickReset() {
    // Check if scores are high enough to warrant undo option
    if (leftScore > 10 || rightScore > 10) {
      final previousLeft = leftScore;
      final previousRight = rightScore;
      final previousServerWasLeft = isLeftServing;

      setState(() {
        leftScore = 0;
        rightScore = 0;
        totalPoints = 0;
        _undoHistory.clear();
        _resetServingIndicator();
      });
      HapticFeedback.mediumImpact();

      // Show snackbar with undo option
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scores reset',
              style: TextStyle(fontFamily: 'Poppins')),
          duration: Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                leftScore = previousLeft;
                rightScore = previousRight;
                totalPoints = previousLeft + previousRight;
                isLeftServing = previousServerWasLeft;
              });
            },
          ),
        ),
      );
    } else {
      setState(() {
        leftScore = 0;
        rightScore = 0;
        totalPoints = 0;
        _undoHistory.clear();
        _resetServingIndicator();
      });
      HapticFeedback.mediumImpact();
    }
  }

  void _nextTheme() {
    final currentIndex = AppThemes.themeKeys.indexOf(widget.currentTheme);
    final nextIndex = (currentIndex + 1) % AppThemes.themeKeys.length;
    widget.onThemeChange(AppThemes.themeKeys[nextIndex]);
    HapticFeedback.lightImpact();
  }

  void _previousTheme() {
    final currentIndex = AppThemes.themeKeys.indexOf(widget.currentTheme);
    final previousIndex =
        (currentIndex - 1 + AppThemes.themeKeys.length) % AppThemes.themeKeys.length;
    widget.onThemeChange(AppThemes.themeKeys[previousIndex]);
    HapticFeedback.lightImpact();
  }

  Future<void> _animateScoreButton(bool isLeft) async {
    setState(() {
      if (isLeft) {
        _isLeftScaling = true;
      } else {
        _isRightScaling = true;
      }
    });

    await _scaleController.forward();
    await _scaleController.reverse();

    setState(() {
      if (isLeft) {
        _isLeftScaling = false;
      } else {
        _isRightScaling = false;
      }
    });
  }

  Widget _buildMenuButton({
    required Color color,
    required Color textColor,
  }) {
    return Semantics(
      label: 'Menu button. Tap for menu, long press to reset scores',
      button: true,
      child: GestureDetector(
        onTap: () {
          _safeAction(() => _showMenuDialog());
        },
        onLongPress: () {
          _safeAction(() => _quickReset());
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                "⋮",
                style: TextStyle(
                  fontSize: AppConstants.controlTextSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: textColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _player.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Score?",
              style: TextStyle(fontFamily: 'Poppins')),
          content: const Text("Are you sure you want to reset both scores?",
              style: TextStyle(fontFamily: 'Poppins')),
          actions: [
            TextButton(
              child: const Text("No", style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes", style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () {
                _safeAction(() {
                  setState(() {
                    leftScore = 0;
                    rightScore = 0;
                    totalPoints = 0;
                    _undoHistory.clear();
                    _resetServingIndicator();
                  });
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showThemeSelector() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Select Theme",
              style: TextStyle(fontFamily: 'Poppins')),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: AppThemes.themes.entries.map((entry) {
                final isSelected = entry.key == widget.currentTheme;
                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Theme color preview swatches
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: entry.value.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: entry.value.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(width: 4),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: entry.value.background,
                          border: Border.all(color: Colors.grey),
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
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: entry.value.primary)
                      : null,
                  onTap: () {
                    widget.onThemeChange(entry.key);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppThemes.themes[widget.currentTheme] ??
        AppThemes.themes[ThemeKeys.defaultTheme]!;

    return Scaffold(
      backgroundColor: theme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildScoreSection(theme),
            _buildControlSection(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreSection(ThemeColors theme) {
    return Expanded(
      flex: AppConstants.scoreSectionFlex,
      child: GestureDetector(
        onPanEnd: (details) {
          final velocity = details.velocity.pixelsPerSecond;
          final isHorizontalSwipe = velocity.dx.abs() > velocity.dy.abs();
          final isFastSwipe = velocity.dx.abs() > 500;

          if (isHorizontalSwipe && isFastSwipe) {
            if (velocity.dx > 0) {
              _previousTheme();
            } else {
              _nextTheme();
            }
          }
        },
        child: Column(
          children: [
            // Games counter row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Semantics(
                    label: 'Left player games won: $leftGames',
                    child: Text(
                      "Games: $leftGames",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.onSurface.withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  // Serving indicator and target score
                  Semantics(
                    label: isLeftServing
                        ? 'Left player serving'
                        : 'Right player serving',
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Playing to $targetScore",
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.onSurface.withValues(alpha: 0.5),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLeftServing)
                              Icon(Icons.sports_tennis,
                                  color: theme.primary, size: 20),
                            Text(
                              " SERVE ",
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.accent,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!isLeftServing)
                              Icon(Icons.sports_tennis,
                                  color: theme.secondary, size: 20),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Semantics(
                    label: 'Right player games won: $rightGames',
                    child: Text(
                      "Games: $rightGames",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.onSurface.withValues(alpha: 0.7),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Score buttons
            Expanded(
              child: Row(
                children: [
                  _buildGridItem(
                    _buildScoreButton(
                      score: leftScore,
                      onTap: () {
                        _animateScoreButton(true);
                        _incrementScore(true);
                      },
                      color: theme.primary,
                      textColor: theme.onSurface,
                      isScaling: _isLeftScaling,
                      isServing: isLeftServing,
                      servingColor: theme.accent,
                      isGamePoint: _isGamePoint(leftScore, rightScore),
                      gamePointColor: theme.gamePoint,
                    ),
                  ),
                  _buildGridItem(
                    _buildScoreButton(
                      score: rightScore,
                      onTap: () {
                        _animateScoreButton(false);
                        _incrementScore(false);
                      },
                      color: theme.secondary,
                      textColor: theme.onSurface,
                      isScaling: _isRightScaling,
                      isServing: !isLeftServing,
                      servingColor: theme.accent,
                      isGamePoint: _isGamePoint(rightScore, leftScore),
                      gamePointColor: theme.gamePoint,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection(ThemeColors theme) {
    return Expanded(
      flex: AppConstants.controlSectionFlex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left minus button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildControlButton(
                    text: "-",
                    onTap: () {
                      _safeAction(() {
                        if (leftScore > 0) {
                          setState(() {
                            leftScore--;
                            totalPoints--;
                          });
                        }
                      });
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
                    semanticsLabel: 'Decrease left score',
                  ),
                ),
              ),
            ),
            // Undo button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildControlButton(
                    text: "↩",
                    onTap: () {
                      _safeAction(() => _undo());
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
                    semanticsLabel: 'Undo last score change',
                    enabled: _undoHistory.isNotEmpty,
                  ),
                ),
              ),
            ),
            // Menu button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildMenuButton(
                    color: theme.accent,
                    textColor: theme.onSurface,
                  ),
                ),
              ),
            ),
            // Swap sides button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildControlButton(
                    text: "⇄",
                    onTap: () {
                      _safeAction(() => _swapSides());
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
                    semanticsLabel: 'Swap sides',
                  ),
                ),
              ),
            ),
            // Right minus button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildControlButton(
                    text: "-",
                    onTap: () {
                      _safeAction(() {
                        if (rightScore > 0) {
                          setState(() {
                            rightScore--;
                            totalPoints--;
                          });
                        }
                      });
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
                    semanticsLabel: 'Decrease right score',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMenuDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Menu", style: TextStyle(fontFamily: 'Poppins')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text("Reset Score",
                    style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  _safeAction(() {
                    Navigator.of(context).pop();
                    _showResetConfirmation();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text("Reset Match",
                    style: TextStyle(fontFamily: 'Poppins')),
                subtitle: const Text("Reset scores and games",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                onTap: () {
                  _safeAction(() {
                    setState(() {
                      leftScore = 0;
                      rightScore = 0;
                      leftGames = 0;
                      rightGames = 0;
                      totalPoints = 0;
                      _undoHistory.clear();
                      _resetServingIndicator();
                    });
                    Navigator.of(context).pop();
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text("Game Settings",
                    style: TextStyle(fontFamily: 'Poppins')),
                subtitle: Text("Target: $targetScore points",
                    style: TextStyle(fontFamily: 'Poppins', fontSize: 12)),
                onTap: () {
                  Navigator.of(context).pop();
                  _showGameSettingsDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Change Theme",
                    style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  _safeAction(() {
                    Navigator.of(context).pop();
                    _showThemeSelector();
                  });
                },
              ),
              ListTile(
                leading:
                    Icon(soundEnabled ? Icons.volume_up : Icons.volume_off),
                title: Text(soundEnabled ? "Sound On" : "Sound Off",
                    style: const TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  _safeAction(() {
                    setState(() {
                      soundEnabled = !soundEnabled;
                    });
                    _savePreferences();
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGameSettingsDialog() {
    final TextEditingController controller = TextEditingController(
      text: targetScore.toString(),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Game Settings",
              style: TextStyle(fontFamily: 'Poppins')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Target Score",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'Enter target score',
                  hintText: 'e.g., 21, 25, 31',
                  border: OutlineInputBorder(),
                  helperText: 'Minimum: ${AppConstants.minTargetScore}',
                ),
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
              const SizedBox(height: 8),
              Text(
                'Win at target with 2-point lead, or sudden death at target + ${AppConstants.maxScoreOffset}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel",
                  style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Save",
                  style: TextStyle(fontFamily: 'Poppins')),
              onPressed: () {
                final newTarget = int.tryParse(controller.text);
                if (newTarget != null && newTarget >= AppConstants.minTargetScore) {
                  setState(() {
                    targetScore = newTarget;
                  });
                  _savePreferences();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Target must be at least ${AppConstants.minTargetScore}',
                        style: TextStyle(fontFamily: 'Poppins'),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridItem(Widget child) {
    return Expanded(
      child: Padding(
        padding: AppConstants.gridPadding,
        child: child,
      ),
    );
  }

  Widget _buildScoreButton({
    required int score,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    required bool isScaling,
    required bool isServing,
    required Color servingColor,
    required bool isGamePoint,
    required Color gamePointColor,
  }) {
    // Use game point color when at game point
    final effectiveColor = isGamePoint ? gamePointColor : color;

    return Semantics(
      label: isGamePoint
          ? 'Score: $score. Game point! Tap to increment'
          : 'Score: $score. Tap to increment',
      button: true,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          final scale = isScaling ? _scaleAnimation.value : 1.0;
          return Transform.scale(
            scale: scale,
            child: Material(
              elevation: 8,
              shadowColor: Colors.black26,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: effectiveColor,
                    borderRadius: BorderRadius.circular(16),
                    border: isServing
                        ? Border.all(color: servingColor, width: 4)
                        : null,
                    boxShadow: isGamePoint
                        ? [
                            BoxShadow(
                              color: gamePointColor.withValues(alpha: 0.5),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      "$score",
                      style: TextStyle(
                        fontSize: AppConstants.scoreTextSize,
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildControlButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
    String? semanticsLabel,
    bool enabled = true,
  }) {
    return Semantics(
      label: semanticsLabel ?? text,
      button: true,
      enabled: enabled,
      child: OutlinedButton(
        onPressed: enabled ? onTap : null,
        style: OutlinedButton.styleFrom(
          backgroundColor: enabled
              ? color.withValues(alpha: 0.1)
              : color.withValues(alpha: 0.05),
          side: BorderSide(
            color: enabled ? color : color.withValues(alpha: 0.3),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.zero,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppConstants.controlTextSize,
              color: enabled ? textColor : textColor.withValues(alpha: 0.3),
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}
