import 'package:flutter/material.dart';

class ColorSettingTile extends StatelessWidget {
  final String title;
  final Color currentColor;
  final void Function(String colorName) onColorChanged;
  final VoidCallback onReset;
  final List<DropdownMenuItem<Color>> colorItems;

  const ColorSettingTile({
    super.key,
    required this.title,
    required this.currentColor,
    required this.onColorChanged,
    required this.onReset,
    required this.colorItems,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: currentColor,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.black12),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _getSelectedColorName(),
              items:
                  colorItems.map((item) {
                    final label = (item.child as Row).children.last as Text;
                    return DropdownMenuItem<String>(
                      value: label.data,
                      child: item.child,
                    );
                  }).toList(),
              onChanged: (colorName) {
                if (colorName != null) {
                  onColorChanged(colorName);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset to default',
            onPressed: onReset,
          ),
        ],
      ),
    );
  }

  String? _getSelectedColorName() {
    for (final item in colorItems) {
      final label = (item.child as Row).children.last as Text;
      if (item.value == currentColor) {
        return label.data;
      }
    }
    return null;
  }
}
