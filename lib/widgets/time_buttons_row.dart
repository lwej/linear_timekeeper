import 'package:flutter/material.dart';

import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/widgets/time_button.dart';

class TimeButtonsRow extends StatelessWidget {
  final TimerData timerData;
  const TimeButtonsRow({super.key, required this.timerData});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('timeButtonsRow'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: timerData.timerController.presetMinutesList
          .map<Widget>((int minutes) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: TimeButton(
              minutes: minutes,
              isSelected:
                  timerData.timerController.duration.inSeconds == minutes * 60,
            ),
          ),
        );
      }).toList(),
    );
  }
}
