import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:linear_timekeeper/main.dart'; // TODO: Remove later (For the silly debugMode variable)

import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/theme/custom_timer_colors.dart';
import 'package:linear_timekeeper/utils/color_utils.dart';
import 'package:linear_timekeeper/utils/time_button_utils.dart';

/// A button widget for setting a preset timer duration.
class TimeButton extends StatelessWidget {
  const TimeButton({
    super.key,
    required this.minutes,
    required this.isSelected,
  });

  final int minutes;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomTimerColors>()!;

    final int presetValue = debugMode ? minutes : minutes * 60;

    final TimerData timerData = Provider.of<TimerData>(context);

    final TimeButtonState state = getTimeButtonState(
      minutes: minutes,
      timerController: timerData.timerController,
      debugMode: debugMode,
    );

    Color backgroundColor;
    final Color selectedColor =
        customColors.timeButtonColors[minutes] ?? Colors.grey[700]!;

    switch (state) {
      case TimeButtonState.active:
        backgroundColor =
            isSelected ? selectedColor : getDesaturatedColor(selectedColor);
        break;
      case TimeButtonState.elapsed:
        backgroundColor = customColors.inactiveButtonColor;
        break;
      case TimeButtonState.future:
        backgroundColor = Colors.grey[400]!;
        break;
    }

    return ElevatedButton(
      onPressed: timerData.timerController.timerState == TimerState.running
          ? null
          : () {
              timerData.timerController.setDuration(presetValue);
            },
      style: ElevatedButton.styleFrom(
        // TODO: proper colors for text??
        // foregroundColor: customColors.text,
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor, // Visual cue for disabled
        disabledForegroundColor: Colors.grey[700], // Visual cue for disabled
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: const Size.fromHeight(50),
      ),
      child: Text('$minutes min'), // Label still shows minutes
    );
  }
}
