import 'package:linear_timekeeper/model/timer_controller.dart';

enum TimeButtonState {
  active,
  elapsed,
  future,
}

TimeButtonState getTimeButtonState({
  required int minutes,
  required TimerController timerController,
  required bool debugMode,
}) {
  final int index = timerController.presetMinutesList.indexOf(minutes);
  final int prevMinutes =
      index == 0 ? 0 : timerController.presetMinutesList[index - 1];
  final int sectionSize = minutes - prevMinutes;
  final int presetSectionStart = minutes - sectionSize + 1;
  final int remainingUnits = debugMode
      ? timerController.remainingTime.inSeconds
      : timerController.remainingTime.inMinutes;
  final int selectedUnits = debugMode
      ? timerController.duration.inSeconds
      : timerController.duration.inMinutes;

  if (timerController.timerState == TimerState.running ||
      timerController.timerState == TimerState.paused) {
    if (remainingUnits < presetSectionStart) {
      return TimeButtonState.elapsed;
    }
  } else {
    if (selectedUnits < presetSectionStart) {
      return TimeButtonState.future;
    }
  }
  return TimeButtonState.active;
}
