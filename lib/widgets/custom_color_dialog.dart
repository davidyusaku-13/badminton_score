import 'package:flutter/material.dart';

/// Full color palette dialog: pick a hue, then a shade.
///
/// Returns the selected color on OK, or null when cancelled.
class CustomColorDialog extends StatefulWidget {
  final Color initialColor;

  const CustomColorDialog({super.key, required this.initialColor});

  @override
  State<CustomColorDialog> createState() => _CustomColorDialogState();
}

class _CustomColorDialogState extends State<CustomColorDialog> {
  static const List<int> _shades = [
    50,
    100,
    200,
    300,
    400,
    500,
    600,
    700,
    800,
    900,
  ];

  late MaterialColor _hue;
  late Color _selected;

  @override
  void initState() {
    super.initState();
    _hue = _closestHue(widget.initialColor);
    _selected = widget.initialColor;
  }

  /// Finds the Material hue closest to [color] in RGB space.
  MaterialColor _closestHue(Color color) {
    MaterialColor best = Colors.primaries.first;
    var bestDistance = double.infinity;
    for (final hue in Colors.primaries) {
      final mid = hue[500]!;
      final distance =
          ((mid.r - color.r) * 255).abs() +
          ((mid.g - color.g) * 255).abs() +
          ((mid.b - color.b) * 255).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = hue;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              key: const Key('custom-color-preview'),
              height: 48,
              decoration: BoxDecoration(
                color: _selected,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < Colors.primaries.length; i++)
                  _PaletteSwatch(
                    key: Key('custom-hue-$i'),
                    color: Colors.primaries[i][500]!,
                    selected: Colors.primaries[i] == _hue,
                    onTap: () => setState(() => _hue = Colors.primaries[i]),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (var i = 0; i < _shades.length; i++)
                  _PaletteSwatch(
                    key: Key('custom-shade-$i'),
                    color: _hue[_shades[i]]!,
                    selected: _hue[_shades[i]] == _selected,
                    onTap: () =>
                        setState(() => _selected = _hue[_shades[i]]!),
                  ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_selected),
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class _PaletteSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _PaletteSwatch({
    super.key,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final checkColor = color.computeLuminance() > 0.4
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
              ? Icon(Icons.check, size: 20, color: checkColor)
              : null,
        ),
      ),
    );
  }
}
