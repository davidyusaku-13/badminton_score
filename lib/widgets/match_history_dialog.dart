import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/theme.dart';
import '../models/match_result.dart';
import 'glass_container.dart';

class MatchHistoryDialog extends StatelessWidget {
  final ThemeColors theme;
  final List<MatchResult> history;
  final VoidCallback? onClearHistory;

  const MatchHistoryDialog({
    super.key,
    required this.theme,
    required this.history,
    this.onClearHistory,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(date)}';
    } else if (diff.inDays < 7) {
      return DateFormat('EEEE, h:mm a').format(date);
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        color: theme.surface,
        opacity: 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Match History",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.textPrimary,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (history.isNotEmpty && onClearHistory != null)
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: theme.textSecondary),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text("Clear History?"),
                              content: const Text("This will delete all match records."),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    onClearHistory?.call();
                                    Navigator.pop(context);
                                  },
                                  child: const Text("Clear", style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    IconButton(
                      icon: Icon(Icons.close, color: theme.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.history, size: 48, color: theme.textSecondary.withOpacity(0.5)),
                      const SizedBox(height: 8),
                      Text(
                        "No matches yet",
                        style: TextStyle(color: theme.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Completed games will appear here",
                        style: TextStyle(color: theme.textSecondary.withOpacity(0.7), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                height: 300,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final match = history[history.length - 1 - index]; // Reverse order (newest first)
                    final isLeftWinner = match.winner == match.leftPlayerName;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.background.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.glassBorder),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${match.leftPlayerName} vs ${match.rightPlayerName}",
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${match.leftScore} - ${match.rightScore}",
                                  style: TextStyle(
                                    color: theme.textPrimary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  _formatDate(match.date),
                                  style: TextStyle(
                                    color: theme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isLeftWinner 
                                  ? Colors.green.withOpacity(0.2) 
                                  : Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${match.winner} Won",
                              style: TextStyle(
                                color: isLeftWinner 
                                    ? Colors.green 
                                    : Colors.orange,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
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
