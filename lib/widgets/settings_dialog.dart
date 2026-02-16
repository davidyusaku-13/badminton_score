import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../models/app_constants.dart';
import 'glass_container.dart';

class SettingsDialog extends StatelessWidget {
  final ThemeColors theme;
  final int targetScore;
  final Function(int) onTargetScoreChanged;
  final bool soundEnabled;
  final Function(bool) onSoundChanged;

  const SettingsDialog({
    super.key,
    required this.theme,
    required this.targetScore,
    required this.onTargetScoreChanged,
    required this.soundEnabled,
    required this.onSoundChanged,
  });

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
            Text(
              "Settings",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            _buildSettingRow(
              "Target Score",
              DropdownButton<int>(
                value: targetScore,
                dropdownColor: theme.surface,
                style: TextStyle(
                  color: theme.textPrimary,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                ),
                underline: Container(height: 2, color: theme.primary),
                items: AppConstants.targetScoreOptions.map((score) {
                  return DropdownMenuItem(
                    value: score,
                    child: Text("$score Points"),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onTargetScoreChanged(val);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSettingRow(
              "Sound Effects",
              Switch(
                value: soundEnabled,
                onChanged: onSoundChanged,
                activeThumbColor: theme.primary,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: theme.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Done",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(String label, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            color: theme.textPrimary,
          ),
        ),
        control,
      ],
    );
  }
}
