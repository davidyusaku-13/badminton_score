import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'glass_container.dart';

class WinDialog extends StatelessWidget {
  final String winnerName;
  final int leftScore;
  final int rightScore;
  final int targetScore;
  final ThemeColors theme;
  final VoidCallback onNewGame;
  final VoidCallback onContinue;

  const WinDialog({
    super.key,
    required this.winnerName,
    required this.leftScore,
    required this.rightScore,
    required this.targetScore,
    required this.theme,
    required this.onNewGame,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        color: theme.surface,
        opacity: 0.95,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              "Game Won!",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.gamePoint, // Gold/Amber
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "$winnerName Wins!",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.glassBorder),
              ),
              child: Text(
                "$leftScore - $rightScore",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: theme.textPrimary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "First to $targetScore",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: theme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onContinue,
                    child: Text(
                      "Continue Match",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: theme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.gamePoint,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                    ),
                     onPressed: onNewGame,
                    child: const Text(
                      "New Game",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
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
