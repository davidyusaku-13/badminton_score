import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'glass_container.dart';

class ScoreCard extends StatelessWidget {
  final int score;
  final String playerName;
  final bool isServing;
  final bool isWinner;
  final VoidCallback onTap;
  final VoidCallback onSwipeDown;
  final VoidCallback onNameTap;
  final ThemeColors theme;

  const ScoreCard({
    super.key,
    required this.score,
    required this.playerName,
    required this.isServing,
    this.isWinner = false,
    required this.onTap,
    required this.onSwipeDown,
    required this.onNameTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onVerticalDragEnd: (details) {
        if (details.primaryVelocity! > 0) {
          onSwipeDown();
        }
      },
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        color: isWinner 
            ? theme.gamePoint.withOpacity(0.2) 
            : theme.surface.withOpacity(0.3),
        border: Border.all(
          color: isServing ? theme.accent : Colors.white12,
          width: isServing ? 3 : 1,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: onNameTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      playerName,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: theme.textSecondary,
                      ),
                    ),
                    if (isServing) ...[
                      const SizedBox(width: 8),
                      Icon(Icons.sports_tennis, color: theme.accent, size: 20),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: FittedBox(
                fit: BoxFit.contain,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Text(
                    score.toString(),
                    key: ValueKey<int>(score),
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.bold,
                      color: isWinner ? theme.gamePoint : theme.textPrimary,
                      shadows: [
                        Shadow(
                          blurRadius: 20,
                          color: isWinner 
                              ? theme.gamePoint.withOpacity(0.5) 
                              : Colors.transparent,
                        ),
                      ],
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
