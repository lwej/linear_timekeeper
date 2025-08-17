import 'package:flutter/material.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/utils/time_screen_utils.dart';

// Manual duration input via Slider when no presets are available
class ManualSlider extends StatelessWidget {
  final TimerData timerData;
  final bool isRunning;
  final bool isPaused;

  const ManualSlider({
    super.key,
    required this.timerData,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('manualSliderColumn'),
      children: <Widget>[
        Text(
          'Set duration: ${formatDuration(timerData.timerController.duration)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          // Slider value represents total seconds
          value: timerData.timerController.duration.inSeconds.toDouble(),
          min: 1.0, // Minimum duration of 1 second
          max: (timerData.timerController.maxPresetMinutes * 60)
              .toDouble(), // Max duration in seconds
          divisions: (timerData.timerController.maxPresetMinutes * 60) > 1
              ? (timerData.timerController.maxPresetMinutes * 60) - 1
              : null,
          label: formatDuration(
              Duration(seconds: timerData.timerController.duration.inSeconds)),
          onChanged: (isRunning || isPaused)
              ? null // Disable slider if timer is running or paused
              : (double value) {
                  timerData.timerController.setManualDuration(value.round());
                },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Adjust the slider to set your desired timer duration (1 second - ${timerData.timerController.maxPresetMinutes * 60} seconds).',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
