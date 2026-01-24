import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../widgets/glass_container.dart';

class RenameDialog extends StatefulWidget {
  final ThemeColors theme;
  final String leftName;
  final String rightName;
  final Function(String, String) onSave;

  const RenameDialog({
    super.key,
    required this.theme,
    required this.leftName,
    required this.rightName,
    required this.onSave,
  });

  @override
  State<RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<RenameDialog> {
  late TextEditingController _leftController;
  late TextEditingController _rightController;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController(text: widget.leftName);
    _rightController = TextEditingController(text: widget.rightName);
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(24),
        color: widget.theme.surface,
        opacity: 0.95,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Player Names",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: widget.theme.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _leftController,
              decoration: InputDecoration(
                labelText: "Left Player",
                labelStyle: TextStyle(color: widget.theme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.primary),
                ),
                prefixIcon: Icon(Icons.person, color: widget.theme.primary),
              ),
              style: TextStyle(color: widget.theme.textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _rightController,
              decoration: InputDecoration(
                labelText: "Right Player",
                 labelStyle: TextStyle(color: widget.theme.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.textSecondary.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.theme.secondary),
                ),
                prefixIcon: Icon(Icons.person, color: widget.theme.secondary),
              ),
              style: TextStyle(color: widget.theme.textPrimary, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: widget.theme.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.theme.primary,
                      foregroundColor: widget.theme.onSurface,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 4,
                    ),
                     onPressed: () {
                         widget.onSave(
                           _leftController.text.trim().isEmpty ? 'Left' : _leftController.text.trim(),
                           _rightController.text.trim().isEmpty ? 'Right': _rightController.text.trim()
                         );
                         Navigator.pop(context);
                     },
                    child: const Text(
                      "Save",
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
