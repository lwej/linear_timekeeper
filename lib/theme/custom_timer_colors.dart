import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:linear_timekeeper/utils/color_utils.dart';
// ignore_for_file: deprecated_member_use

@immutable
class CustomTimerColors extends ThemeExtension<CustomTimerColors> {
  const CustomTimerColors({
    required this.activeDotColor,
    required this.inactiveDotColor,
    required this.playButtonColor,
    required this.pauseButtonColor,
    required this.stopButtonColor,
    required this.inactiveButtonColor,
    required this.timeButtonColors,
  });

  final Color activeDotColor;
  final Color inactiveDotColor;
  final Color playButtonColor;
  final Color pauseButtonColor;
  final Color stopButtonColor;
  final Color inactiveButtonColor;
  final Map<int, Color> timeButtonColors;

  @override
  CustomTimerColors copyWith({
    Color? activeDotColor,
    Color? inactiveDotColor,
    Color? playButtonColor,
    Color? pauseButtonColor,
    Color? stopButtonColor,
    Color? inactiveButtonColor,
    Map<int, Color>? timeButtonColors,
  }) {
    return CustomTimerColors(
      activeDotColor: activeDotColor ?? this.activeDotColor,
      inactiveDotColor: inactiveDotColor ?? this.inactiveDotColor,
      playButtonColor: playButtonColor ?? this.playButtonColor,
      pauseButtonColor: pauseButtonColor ?? this.pauseButtonColor,
      stopButtonColor: stopButtonColor ?? this.stopButtonColor,
      inactiveButtonColor: inactiveButtonColor ?? this.inactiveButtonColor,
      timeButtonColors: timeButtonColors ?? this.timeButtonColors,
    );
  }

  @override
  CustomTimerColors lerp(ThemeExtension<CustomTimerColors>? other, double t) {
    if (other is! CustomTimerColors) {
      return this;
    }

    final Color lerpedActiveDotColor =
        Color.lerp(activeDotColor, other.activeDotColor, t)!;
    final Color lerpedInactiveDotColor =
        Color.lerp(inactiveDotColor, other.inactiveDotColor, t)!;
    final Color lerpedPlayButtonColor =
        Color.lerp(playButtonColor, other.playButtonColor, t)!;
    final Color lerpedPauseButtonColor =
        Color.lerp(pauseButtonColor, other.pauseButtonColor, t)!;
    final Color lerpedStopButtonColor =
        Color.lerp(stopButtonColor, other.stopButtonColor, t)!;
    final Color lerpedInactiveButtonColor =
        Color.lerp(inactiveButtonColor, other.inactiveButtonColor, t)!;

    final Map<int, Color> lerpedTimeButtonColors = <int, Color>{};
    for (final int key in kTimerPresetMinutes) {
      final Color? thisColor = timeButtonColors[key];
      final Color? otherColor = other.timeButtonColors[key];

      if (thisColor != null && otherColor != null) {
        lerpedTimeButtonColors[key] = Color.lerp(thisColor, otherColor, t)!;
      } else if (thisColor != null) {
        lerpedTimeButtonColors[key] = thisColor;
      } else if (otherColor != null) {
        lerpedTimeButtonColors[key] = otherColor;
      } else {
        lerpedTimeButtonColors[key] = Colors.grey;
      }
    }

    return CustomTimerColors(
      activeDotColor: lerpedActiveDotColor,
      inactiveDotColor: lerpedInactiveDotColor,
      playButtonColor: lerpedPlayButtonColor,
      pauseButtonColor: lerpedPauseButtonColor,
      stopButtonColor: lerpedStopButtonColor,
      inactiveButtonColor: lerpedInactiveButtonColor,
      timeButtonColors: lerpedTimeButtonColors,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'activeDotColor': activeDotColor.value,
      'inactiveDotColor': inactiveDotColor.value,
      'playButtonColor': playButtonColor.value,
      'pauseButtonColor': pauseButtonColor.value,
      'stopButtonColor': stopButtonColor.value,
      'timeButtonColors': timeButtonColors.map<String, int>(
          (int k, Color v) => MapEntry<String, int>(k.toString(), v.value)),
      'inactiveButtonColor': inactiveButtonColor.value,
    };
  }
}

CustomTimerColors mergeTimerColorsWithOverrides(
    Flavor flavor, Map<String, String> overrides) {
  final resolved = resolveAllTimerColors(flavor, overrides,
      presetMinutes: kTimerPresetMinutes);

  return CustomTimerColors(
    activeDotColor: resolved['activeDotColor']!,
    inactiveDotColor: resolved['inactiveDotColor']!,
    playButtonColor: resolved['playButtonColor']!,
    pauseButtonColor: resolved['pauseButtonColor']!,
    stopButtonColor: resolved['stopButtonColor']!,
    inactiveButtonColor: resolved['inactiveButtonColor']!,
    timeButtonColors: resolved['timeButtonColors'] as Map<int, Color>,
  );
}
