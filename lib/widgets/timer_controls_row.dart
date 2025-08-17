import 'package:flutter/material.dart';

import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/theme/custom_timer_colors.dart';
import 'package:linear_timekeeper/utils/color_utils.dart';
import 'package:linear_timekeeper/utils/time_screen_utils.dart';

class TimerControlsRow extends StatelessWidget {
  final TimerData timerData;
  final CustomTimerColors customColors;
  final bool isRunning;
  final bool isPaused;

  const TimerControlsRow({
    super.key,
    required this.timerData,
    required this.customColors,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Digital Timer
        if (timerData.showDigitalTimer)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              formatDuration(timerData.timerController.remainingTime),
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
        const SizedBox(width: 40),
        // Play/Pause Button
        if (isRunning)
          IconButton(
            icon: const Icon(Icons.pause),
            iconSize: 64,
            onPressed: timerData.timerController.pauseTimer,
            color: getDesaturatedColor(customColors
                .pauseButtonColor), // Desaturate pause button when running
            tooltip: 'Pause Timer',
          )
        else // If paused, initial, or stopped
          IconButton(
            icon: const Icon(Icons.play_arrow),
            iconSize: 64,
            // Enable play button if duration is set, or if there's remaining time
            onPressed: (timerData.timerController.duration.inSeconds > 0 ||
                    timerData.timerController.remainingTime.inSeconds > 0)
                ? timerData.timerController.startTimer
                : null,
            color: (timerData.timerController.duration.inSeconds > 0 ||
                    timerData.timerController.remainingTime.inSeconds > 0)
                ? customColors
                    .playButtonColor // Use custom color (not desaturated as it's not running)
                : Colors.grey,
            tooltip: 'Start Timer',
          ),
        const SizedBox(width: 24),
        // Stop Button
        IconButton(
          icon: const Icon(Icons.stop),
          iconSize: 64,
          onPressed: (isRunning || isPaused)
              ? () async {
                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Confirm Stop'),
                        content: const Text(
                            'Are you sure you want to stop the timer?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child: const Text('Stop'),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm == true) {
                    timerData.timerController.stopTimer();
                  }
                }
              : null,
          color: (isRunning || isPaused)
              ? (isRunning
                  ? getDesaturatedColor(customColors
                      .stopButtonColor) // Desaturate stop button if running
                  : customColors.stopButtonColor)
              : Colors.grey,
          tooltip: 'Stop Timer',
        ),
      ],
    );
  }
}
