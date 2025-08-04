import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// Constants
class AppConstants {
  static const int scoreSectionFlex = 75;
  static const int controlSectionFlex = 25;
  static const double scoreTextSize = 220;
  static const double controlTextSize = 50;
  static const double buttonTextSize = 30;
  static const EdgeInsets gridPadding =
      EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0);
}

class ThemeKeys {
  static const String dark = 'dark';
  static const String light = 'light';
  static const String sunset = 'sunset';
  static const String forest = 'forest';
  static const String ocean = 'ocean';
  static const String neon = 'neon';
  static const String minimal = 'minimal';
  static const String defaultTheme = dark;
}

class AppThemes {
  static final Map<String, ThemeColors> themes = {
    'dark': ThemeColors(
      name: 'Dark',
      background: const Color(0xFF121212),
      primary: const Color(0xFF7C4DFF), // Brighter Purple
      secondary: const Color(0xFF00E5FF), // Bright Cyan
      surface: const Color(0xFF2A2A2A),
      onSurface: Colors.white,
      accent: const Color(0xFFE91E63), // Pink accent
    ),
    'light': ThemeColors(
      name: 'Light',
      background: const Color(0xFFFAFAFA),
      primary: const Color(0xFF6200EE), // Material Purple
      secondary: const Color(0xFF00695C), // Dark Teal
      surface: const Color(0xFFE0E0E0),
      onSurface: const Color(0xFF000000),
      accent: const Color(0xFFD32F2F), // Red accent
    ),
    'sunset': ThemeColors(
      name: 'Sunset',
      background: const Color(0xFF1A0E3D),
      primary: const Color(0xFFFF7043), // Bright Orange
      secondary: const Color(0xFFFFD54F), // Bright Yellow
      surface: const Color(0xFF4A2C7A),
      onSurface: Colors.white,
      accent: const Color(0xFFFF5722), // Deep Orange
    ),
    'forest': ThemeColors(
      name: 'Forest',
      background: const Color(0xFF0D2818),
      primary: const Color(0xFF66BB6A), // Bright Green
      secondary: const Color(0xFF42A5F5), // Bright Blue
      surface: const Color(0xFF1B4332),
      onSurface: Colors.white,
      accent: const Color(0xFF8BC34A), // Light Green
    ),
    'ocean': ThemeColors(
      name: 'Ocean',
      background: const Color(0xFF001122),
      primary: const Color(0xFF00BCD4), // Bright Cyan
      secondary: const Color(0xFF2196F3), // Bright Blue
      surface: const Color(0xFF0D47A1),
      onSurface: Colors.white,
      accent: const Color(0xFF03DAC6), // Teal accent
    ),
    'neon': ThemeColors(
      name: 'Neon',
      background: const Color(0xFF000000),
      primary: const Color(0xFF003300), // Medium dark green
      secondary: const Color(0xFF330033), // Medium dark magenta
      surface: const Color(0xFF1A1A1A),
      onSurface: const Color(0xFF00FF41), // Bright neon green text
      accent: const Color(0xFF003366), // Medium dark blue
    ),
    'minimal': ThemeColors(
      name: 'Minimal',
      background: const Color(0xFFFFFFFF),
      primary: const Color(0xFF212121), // Dark Grey button
      secondary: const Color(0xFF424242), // Medium Grey button
      surface: const Color(0xFFF5F5F5),
      onSurface: Colors.white, // WHITE TEXT on colored buttons!
      accent: const Color(0xFF1976D2), // Blue accent
    ),
  };
}

class ThemeColors {
  final String name;
  final Color background;
  final Color primary;
  final Color secondary;
  final Color surface;
  final Color onSurface;
  final Color accent;

  ThemeColors({
    required this.name,
    required this.background,
    required this.primary,
    required this.secondary,
    required this.surface,
    required this.onSurface,
    required this.accent,
  });
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    WakelockPlus.enable(); // Keep screen awake
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

  void changeTheme(String themeName) {
    setState(() {
      currentTheme = themeName;
    });
  }

  @override
  Widget build(BuildContext context) {
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

class _ScoreScreenState extends State<ScoreScreen> {
  int leftScore = 0;
  int rightScore = 0;
  bool soundEnabled = true;

  late AudioPlayer _player;
  late final Source _beepSource;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
    _beepSource = AssetSource('beep.mp3');
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

  void _quickReset() {
    setState(() {
      leftScore = 0;
      rightScore = 0;
    });
    // Provide haptic feedback for long press
    HapticFeedback.mediumImpact();
  }

  void _nextTheme() {
    final themeKeys = AppThemes.themes.keys.toList();
    final currentIndex = themeKeys.indexOf(widget.currentTheme);
    final nextIndex = (currentIndex + 1) % themeKeys.length;
    widget.onThemeChange(themeKeys[nextIndex]);
    HapticFeedback.lightImpact();
  }

  void _previousTheme() {
    final themeKeys = AppThemes.themes.keys.toList();
    final currentIndex = themeKeys.indexOf(widget.currentTheme);
    final previousIndex =
        (currentIndex - 1 + themeKeys.length) % themeKeys.length;
    widget.onThemeChange(themeKeys[previousIndex]);
    HapticFeedback.lightImpact();
  }

  Widget _buildMenuButton({
    required Color color,
    required Color textColor,
  }) {
    return GestureDetector(
      onTap: () {
        _stopSound();
        _showMenuDialog();
      },
      onLongPress: () {
        _stopSound();
        _quickReset();
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
    );
  }

  @override
  void dispose() {
    _player.dispose();
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
                _stopSound();
                setState(() {
                  leftScore = 0;
                  rightScore = 0;
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
                return RadioListTile<String>(
                  title: Text(entry.value.name,
                      style: const TextStyle(fontFamily: 'Poppins')),
                  value: entry.key,
                  groupValue: widget.currentTheme,
                  onChanged: (String? value) {
                    if (value != null) {
                      widget.onThemeChange(value);
                      Navigator.of(context).pop();
                    }
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
          // Theme swipe only in score area
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
        child: Row(
          children: [
            _buildGridItem(
              _buildScoreButton(
                score: leftScore,
                onTap: () {
                  setState(() => leftScore++);
                  _beep();
                },
                color: theme.primary,
                textColor: theme.onSurface,
              ),
            ),
            _buildGridItem(
              _buildScoreButton(
                score: rightScore,
                onTap: () {
                  setState(() => rightScore++);
                  _beep();
                },
                color: theme.secondary,
                textColor: theme.onSurface,
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
                      _stopSound();
                      if (leftScore > 0) {
                        setState(() => leftScore--);
                      }
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
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
            // Right minus button
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: SizedBox(
                  height: 56,
                  child: _buildControlButton(
                    text: "-",
                    onTap: () {
                      _stopSound();
                      if (rightScore > 0) {
                        setState(() => rightScore--);
                      }
                    },
                    color: theme.surface,
                    textColor: theme.onSurface,
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
                  _stopSound();
                  Navigator.of(context).pop();
                  _showResetConfirmation();
                },
              ),
              ListTile(
                leading: const Icon(Icons.palette),
                title: const Text("Change Theme",
                    style: TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  _stopSound();
                  Navigator.of(context).pop();
                  _showThemeSelector();
                },
              ),
              ListTile(
                leading:
                    Icon(soundEnabled ? Icons.volume_up : Icons.volume_off),
                title: Text(soundEnabled ? "Sound On" : "Sound Off",
                    style: const TextStyle(fontFamily: 'Poppins')),
                onTap: () {
                  _stopSound();
                  setState(() {
                    soundEnabled = !soundEnabled;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
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
  }) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
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
    );
  }

  Widget _buildControlButton({
    required String text,
    required VoidCallback onTap,
    required Color color,
    required Color textColor,
  }) {
    if (text == "⋮") {
      // Consistent elevated button style for menu
      return ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 6,
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
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    } else {
      // Outlined style for minus buttons
      return OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: color.withOpacity(0.1),
          side: BorderSide(color: color, width: 2),
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
              color: textColor,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      );
    }
  }
}
