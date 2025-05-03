import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:flutter/services.dart'; // for rootBundle

// App colors
const Color backgroundDark = Color(0xFF121212);
const Color team1Color = Color(0xFF4CAF50); // Green
const Color team2Color = Color(0xFFF44336); // Red
const Color resetColor = Color(0xFFFF9800); // Orange
const Color minusColor = Color(0xFF607D8B); // Blue Grey
const Color textWhite = Colors.white;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    runApp(const BadmintonScoreApp());
  });
}

class BadmintonScoreApp extends StatelessWidget {
  const BadmintonScoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  bool beepEnabled = true;

  final Soundpool _soundpool = Soundpool(streamType: StreamType.notification);
  int? _beepSoundId;
  int? _currentStreamId;

  @override
  void initState() {
    super.initState();
    _loadBeep();
  }

  Future<void> _loadBeep() async {
    final soundData = await rootBundle.load('assets/beep.mp3');
    _beepSoundId = await _soundpool.load(soundData);
  }

  Future<void> _beep() async {
    if (beepEnabled && _beepSoundId != null) {
      // Stop previous sound (if any)
      if (_currentStreamId != null) {
        await _soundpool.stop(_currentStreamId!);
      }
      _currentStreamId = await _soundpool.play(_beepSoundId!);
    }
  }

  @override
  void dispose() {
    _soundpool.release();
    super.dispose();
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Reset Score?"),
          content: const Text("Are you sure you want to reset both scores?"),
          actions: [
            TextButton(
              child: const Text("No"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text("Yes"),
              onPressed: () {
                setState(() {
                  leftScore = 0;
                  rightScore = 0;
                });
                Navigator.of(context).pop();
                _beep();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundDark,
      body: Column(
        children: [
          Expanded(
            flex: 80,
            child: Row(
              children: [
                _buildGridItem(
                  _buildScoreButton(
                    score: leftScore,
                    onTap: () {
                      if (leftScore < 30) {
                        setState(() => leftScore++);
                        _beep();
                      }
                    },
                    color: team1Color,
                  ),
                ),
                _buildGridItem(
                  _buildScoreButton(
                    score: rightScore,
                    onTap: () {
                      if (rightScore < 30) {
                        setState(() => rightScore++);
                        _beep();
                      }
                    },
                    color: team2Color,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 20,
            child: Row(
              children: [
                Expanded(
                  child: _buildGridItem(
                    _buildControlButton(
                      text: "-",
                      onTap: () {
                        if (leftScore > 0) {
                          setState(() => leftScore--);
                          _beep();
                        }
                      },
                      color: minusColor,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildGridItem(
                    _buildControlButton(
                      text: "Reset",
                      onTap: _showResetConfirmation,
                      color: resetColor,
                    ),
                  ),
                ),
                Expanded(
                  child: _buildGridItem(
                    _buildControlButton(
                      text: "-",
                      onTap: () {
                        if (rightScore > 0) {
                          setState(() => rightScore--);
                          _beep();
                        }
                      },
                      color: minusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridItem(Widget child) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: child,
      ),
    );
  }

  Widget _buildScoreButton({
    required int score,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        color: color,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "$score",
            style: const TextStyle(
              fontSize: 160,
              color: textWhite,
              fontWeight: FontWeight.bold,
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
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        color: color,
        child: Text(
          text,
          style: TextStyle(
            fontSize: text == "Reset" ? 30 : 50,
            color: textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
