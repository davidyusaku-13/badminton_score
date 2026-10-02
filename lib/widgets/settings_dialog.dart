import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../game/game_controller.dart';
import '../theme/app_theme.dart';
import 'custom_color_dialog.dart';

/// Preset accent colors pickable per player side.
const List<Color> kAccentChoices = [
  Color(0xFFA3E635), // lime
  Color(0xFF22D3EE), // cyan
  Color(0xFFFB923C), // orange
  Color(0xFFFACC15), // yellow
  Color(0xFFF472B6), // pink
  Color(0xFFFFFFFF), // white
];

/// Selection index used for the custom (color wheel) choice.
const int kCustomColorIndex = 6;

class SettingsDialog extends StatefulWidget {
  final String leftName;
  final String rightName;
  final Color leftColor;
  final Color rightColor;
  final double scoreSize;
  final bool soundEnabled;
  final void Function({
    required String leftName,
    required String rightName,
    required Color leftColor,
    required Color rightColor,
    required double scoreSize,
  })
  onSave;
  final ValueChanged<bool> onSoundChanged;

  const SettingsDialog({
    super.key,
    required this.leftName,
    required this.rightName,
    required this.leftColor,
    required this.rightColor,
    required this.scoreSize,
    required this.soundEnabled,
    required this.onSave,
    required this.onSoundChanged,
  });

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late final TextEditingController _leftController;
  late final TextEditingController _rightController;
  late int _leftColorIndex;
  late int _rightColorIndex;
  late Color _leftCustom;
  late Color _rightCustom;
  late double _scoreSize;
  late bool _soundEnabled;

  @override
  void initState() {
    super.initState();
    _leftController = TextEditingController(text: widget.leftName);
    _rightController = TextEditingController(text: widget.rightName);
    _leftColorIndex = _indexOf(widget.leftColor);
    _rightColorIndex = _indexOf(widget.rightColor);
    _leftCustom = widget.leftColor;
    _rightCustom = widget.rightColor;
    _scoreSize = widget.scoreSize;
    _soundEnabled = widget.soundEnabled;
  }

  int _indexOf(Color color) {
    final index = kAccentChoices.indexOf(color);
    return index < 0 ? kCustomColorIndex : index;
  }

  Color _colorFor({required int index, required Color custom}) {
    return index == kCustomColorIndex ? custom : kAccentChoices[index];
  }

  @override
  void dispose() {
    _leftController.dispose();
    _rightController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave(
      leftName: _leftController.text,
      rightName: _rightController.text,
      leftColor: _colorFor(index: _leftColorIndex, custom: _leftCustom),
      rightColor: _colorFor(index: _rightColorIndex, custom: _rightCustom),
      scoreSize: _scoreSize,
    );
    Navigator.of(context).pop();
  }

  void _resetToDefaults() {
    _leftController.text = kDefaultLeftName;
    _rightController.text = kDefaultRightName;
    setState(() {
      _leftColorIndex = _indexOf(AppTheme.current.accent);
      _rightColorIndex = _indexOf(AppTheme.current.accentSecondary);
      _leftCustom = AppTheme.current.accent;
      _rightCustom = AppTheme.current.accentSecondary;
      _scoreSize = kDefaultScoreSize;
      _soundEnabled = kDefaultSoundEnabled;
    });
    // Sound applies live, so restore it immediately like the switch does.
    widget.onSoundChanged(kDefaultSoundEnabled);
  }

  Future<void> _pickCustomColor({required bool isLeft}) async {    final current = isLeft ? _leftCustom : _rightCustom;
    final picked = await showDialog<Color>(
      context: context,
      builder: (context) => CustomColorDialog(initialColor: current),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      if (isLeft) {
        _leftCustom = picked;
        _leftColorIndex = kCustomColorIndex;
      } else {
        _rightCustom = picked;
        _rightColorIndex = kCustomColorIndex;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlayerSection(
              title: 'Player 1 (left)',
              nameKey: const Key('settings-left-name'),
              controller: _leftController,
              selectedIndex: _leftColorIndex,
              customColor: _leftCustom,
              colorKeyPrefix: 'settings-left-color',
              onColorSelected: (index) =>
                  setState(() => _leftColorIndex = index),
              onCustomTap: () => _pickCustomColor(isLeft: true),
            ),
            const SizedBox(height: 16),
            _PlayerSection(
              title: 'Player 2 (right)',
              nameKey: const Key('settings-right-name'),
              controller: _rightController,
              selectedIndex: _rightColorIndex,
              customColor: _rightCustom,
              colorKeyPrefix: 'settings-right-color',
              onColorSelected: (index) =>
                  setState(() => _rightColorIndex = index),
              onCustomTap: () => _pickCustomColor(isLeft: false),
            ),
            const SizedBox(height: 16),
            Text('Score size', style: Theme.of(context).textTheme.titleSmall),
            Slider(
              key: const Key('settings-score-size'),
              value: _scoreSize,
              min: 8,
              max: 24,
              divisions: 16,
              label: _scoreSize.round().toString(),
              onChanged: (value) => setState(() => _scoreSize = value),
            ),
            Text('Size: ${_scoreSize.round()}'),
            const SizedBox(height: 8),
            SwitchListTile(
              key: const Key('settings-sound'),
              title: const Text('Sound'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() => _soundEnabled = value);
                widget.onSoundChanged(value);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _resetToDefaults,
          child: Text(
            'Reset to defaults',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}

class _PlayerSection extends StatelessWidget {
  final String title;
  final Key nameKey;
  final TextEditingController controller;
  final int selectedIndex;
  final Color customColor;
  final String colorKeyPrefix;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onCustomTap;

  const _PlayerSection({
    required this.title,
    required this.nameKey,
    required this.controller,
    required this.selectedIndex,
    required this.customColor,
    required this.colorKeyPrefix,
    required this.onColorSelected,
    required this.onCustomTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, style: textTheme.titleSmall),
        const SizedBox(height: 8),
        TextField(
          key: nameKey,
          controller: controller,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (var i = 0; i < kAccentChoices.length; i++)
              _ColorSwatch(
                key: Key('$colorKeyPrefix-$i'),
                color: kAccentChoices[i],
                selected: i == selectedIndex,
                onTap: () => onColorSelected(i),
              ),
            _ColorSwatch(
              key: Key('$colorKeyPrefix-custom'),
              color: customColor,
              selected: selectedIndex == kCustomColorIndex,
              unselectedIcon: LucideIcons.palette,
              onTap: onCustomTap,
            ),
          ],
        ),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final IconData? unselectedIcon;
  final VoidCallback onTap;

  const _ColorSwatch({
    super.key,
    required this.color,
    required this.selected,
    this.unselectedIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color.computeLuminance() > 0.4
        ? Colors.black
        : Colors.white;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(
              color: selected ? Colors.white : Colors.white24,
              width: selected ? 3 : 1,
            ),
          ),
          child: selected
              ? Icon(Icons.check, size: 20, color: foreground)
              : (unselectedIcon == null
                    ? null
                    : Icon(unselectedIcon, size: 20, color: foreground)),
        ),
      ),
    );
  }
}
