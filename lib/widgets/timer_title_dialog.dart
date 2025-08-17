import 'package:flutter/material.dart';

class TimerTitleDialog extends StatelessWidget {
  final String initialTitle;
  final String dialogTitle;
  final String hintText;

  const TimerTitleDialog({
    super.key,
    required this.initialTitle,
    required this.dialogTitle,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: initialTitle);
    return AlertDialog(
      title: Text(dialogTitle),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: hintText,
          border: const OutlineInputBorder(),
        ),
        onSubmitted: (value) => Navigator.of(context).pop(controller.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
