import 'package:linear_timekeeper/model/timer_controller.dart';

int calculateActiveDots({
  required bool dotsPerMinute,
  required List<int> presets,
  required int maxTotalDots,
  required int totalDurationMinutes,
  required int selectedMinutes,
  required int remainingSeconds,
  required TimerState timerState,
  required bool debugMode,
}) {
  //TODO: Remove later
  // Adjust remainingSeconds for debugMode
  if (debugMode) {
    remainingSeconds *= 60;
  }
  final int remainingMinutes = (remainingSeconds / 60).ceil();

  int activeDots = maxTotalDots;
  if (!dotsPerMinute && presets.isNotEmpty) {
    int selectedSection = presets.lastIndexWhere((m) => selectedMinutes >= m);
    if (selectedSection == -1) selectedSection = 0;
    final int selectedPresetMinutes = presets[selectedSection];
    activeDots =
        ((selectedPresetMinutes / totalDurationMinutes) * maxTotalDots).round();
    if (timerState == TimerState.running || timerState == TimerState.paused) {
      activeDots =
          ((remainingMinutes / totalDurationMinutes) * maxTotalDots).ceil();
    }
  } else if (!dotsPerMinute) {
    activeDots =
        ((remainingMinutes / totalDurationMinutes) * maxTotalDots).ceil();
  } else {
    activeDots = remainingMinutes;
  }
  return activeDots;
}

bool shouldBlinkProgressBar(TimerController timerController) {
  return timerController.timerState == TimerState.stopped &&
      timerController.remainingTime.inSeconds == 0;
}
