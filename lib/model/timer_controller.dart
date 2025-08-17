import 'dart:async';
import 'package:flutter/material.dart';

enum TimerState {
  initial,
  running,
  paused,
  stopped,
}

class TimerController extends ChangeNotifier {
  Duration _duration;
  Duration _remainingTime;
  TimerState _timerState;
  Timer? _timer;
  int maxPresetMinutes;
  int presetIntervalMinutes;
  VoidCallback? onTimerFinished;

  TimerController(
      {required Duration initialDuration,
      required this.maxPresetMinutes,
      required this.presetIntervalMinutes})
      : _duration = initialDuration,
        _remainingTime = initialDuration,
        _timerState = TimerState.initial;

  Duration get duration => _duration;
  Duration get remainingTime => _remainingTime;
  TimerState get timerState => _timerState;

  // List of standard preset interval values that can be chosen, in minutes.
  final List<int> _availablePresetIntervalValues = const <int>[5, 10, 15, 20];

  /// Returns the list of standard preset interval values (in minutes).
  List<int> get availablePresetIntervalValues => _availablePresetIntervalValues;

  /// Returns a list of calculated minute values for the preset buttons,
  /// based on the current [maxPresetMinutes] and [presetIntervalMinutes].
  /// If [presetIntervalMinutes] is 0, an empty list is returned.
  List<int> get presetMinutesList {
    if (maxPresetMinutes == 8) {
      return [2, 4, 6, 8];
    }
    if (presetIntervalMinutes == 0) {
      return <int>[];
    }
    final List<int> presets = <int>[];
    for (int i = presetIntervalMinutes;
        i <= maxPresetMinutes;
        i += presetIntervalMinutes) {
      presets.add(i);
    }
    return presets;
  }

  /// Helper to generate the dropdown items for preset intervals in settings.
  ///
  /// Filters available intervals based on `maxPresetMinutes / 2` and includes
  /// a "None" option if no standard intervals are applicable.
  List<DropdownMenuItem<int>> getPresetIntervalDropdownItems() {
    final int maxAllowedInterval = maxPresetMinutes ~/ 2;
    final List<DropdownMenuItem<int>> items = <DropdownMenuItem<int>>[];

    // Add all valid standard intervals that evenly divide maxPresetMinutes
    for (final int interval in _availablePresetIntervalValues) {
      if (interval <= maxAllowedInterval && maxPresetMinutes % interval == 0) {
        items.add(
          DropdownMenuItem<int>(
            value: interval,
            child: Text('$interval minutes'),
          ),
        );
      }
    }

    // Always add the "None" option (value 0).
    items.insert(
      0,
      const DropdownMenuItem<int>(
        value: 0,
        child: Text('None'),
      ),
    );

    return items;
  }

  /// Sets a new duration for the timer and starts it.
  /// This method is intended for preset buttons and custom timers.
  ///
  /// The [seconds] parameter specifies the total duration in seconds.
  /// If the selected duration is already active and the timer is running,
  /// no action is taken. Otherwise, the timer is reset to the new duration
  /// and started.
  void setDuration(int seconds) {
    final Duration newDuration = Duration(seconds: seconds);
    if (_duration == newDuration && _timerState == TimerState.running) {
      return; // Do nothing if the same duration is selected while running
    }
    _duration = newDuration;
    _resetTimer(); // Reset remaining time to new duration and set state to initial
    startTimer(); // Immediately start the timer with the new duration
  }

  /// Sets a new duration for the timer without automatically starting it.
  /// This method is intended for manual duration input (e.g., via slider).
  ///
  /// The [seconds] parameter specifies the total duration in seconds.
  /// The duration can only be changed if the timer is not running or paused.
  void setManualDuration(int seconds) {
    final Duration newDuration = Duration(seconds: seconds);
    if (_duration == newDuration) {
      return; // No change needed
    }
    // Only allow manual duration change if timer is not running or paused
    if (_timerState == TimerState.running || _timerState == TimerState.paused) {
      return;
    }
    _duration = newDuration;
    _remainingTime = _duration; // Reset remaining time to new duration
    _timerState = TimerState.initial; // Set state to initial
    notifyListeners();
  }

  /// Sets a new maximum duration for the timer presets (in minutes).
  ///
  /// This will update the available preset button values and reset the
  /// current timer duration to the first preset in the new configuration,
  /// or to the maximum duration itself if no valid presets are available.
  void setMaxDuration(int minutes) {
    if (maxPresetMinutes == minutes) return; // No change needed

    maxPresetMinutes = minutes;

    if (minutes == 8) {
      presetIntervalMinutes = 2;
    }
    final int maxAllowedInterval = maxPresetMinutes ~/ 2;

    int newInterval;
    // Check if any standard preset interval is valid for the new max duration
    final List<int> validStandardIntervals = _availablePresetIntervalValues
        .where((int interval) => interval <= maxAllowedInterval)
        .toList();

    if (validStandardIntervals.isEmpty) {
      // If no standard preset interval (5, 10, 15) is valid (e.g., maxPresetMinutes < 10)
      newInterval = 0; // Represents "None" or no valid preset interval
    } else {
      // Find the largest valid standard interval from the predefined list
      newInterval =
          validStandardIntervals.reduce((int a, int b) => a > b ? a : b);
    }

    // Only update _presetIntervalMinutes if it's different
    if (presetIntervalMinutes != newInterval) {
      presetIntervalMinutes = newInterval;
    }

    // After changing max duration or interval, ensure current duration is valid.
    if (presetMinutesList.isNotEmpty) {
      _duration = Duration(
          seconds: presetMinutesList.first * 60); // Convert minutes to seconds
    } else {
      // If no preset buttons are available (interval is 0), the timer should default to the max duration.
      // Or to 1 minute (60 seconds) if max is less than 1 (unlikely but safe).
      _duration = Duration(
          seconds: (maxPresetMinutes > 0 ? maxPresetMinutes : 1) *
              60); // Convert minutes to seconds
    }

    _resetTimer(); // Reset remaining time to new duration and state to initial
    notifyListeners();
  }

  /// Sets a new interval for the preset buttons (in minutes).
  ///
  /// This will regenerate the preset buttons and reset the current timer
  /// duration to the first valid preset with the new interval,
  /// or to the maximum duration if the interval results in no presets.
  void setPresetInterval(int intervalMinutes) {
    // Validate the incoming interval to ensure it's within rules.
    final int maxAllowedInterval = maxPresetMinutes ~/ 2;

    // Only allow intervals that evenly divide maxPresetMinutes
    if (intervalMinutes != 0 &&
        (intervalMinutes > maxAllowedInterval ||
            maxPresetMinutes % intervalMinutes != 0)) {
      // Invalid interval: either too large or not a divisor
      return;
    }

    // Ensure it's one of our allowed values or 0 for "None"
    if (intervalMinutes != 0 &&
        !_availablePresetIntervalValues.contains(intervalMinutes)) {
      return; // Not a recognized standard interval value
    }

    if (presetIntervalMinutes == intervalMinutes) return;

    presetIntervalMinutes = intervalMinutes;

    // After interval changes, ensure current duration is valid.
    if (presetMinutesList.isNotEmpty) {
      _duration = Duration(
          seconds: presetMinutesList.first * 60); // Convert minutes to seconds
    } else {
      // If no preset buttons are available (interval is 0), the timer should default to the max duration.
      // Or to 1 minute (60 seconds) if max is less than 1 (unlikely but safe).
      _duration = Duration(
          seconds: (maxPresetMinutes > 0 ? maxPresetMinutes : 1) *
              60); // Convert minutes to seconds
    }

    _resetTimer(); // Reset remaining time to new duration and state to initial
    notifyListeners();
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingTime = _duration;
    _timerState = TimerState.initial;
    notifyListeners();
  }

  void startTimer() {
    if (_timerState == TimerState.running) return;
    if (_duration == Duration.zero && _remainingTime == Duration.zero) return;
    if (_remainingTime == Duration.zero && _duration > Duration.zero) {
      _remainingTime = _duration;
    }
    _timerState = TimerState.running;
    _timer = Timer.periodic(const Duration(seconds: 1), _onTick);
    notifyListeners();
  }

  void pauseTimer() {
    if (_timerState != TimerState.running) return;
    _timer?.cancel();
    _timerState = TimerState.paused;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _remainingTime = _duration;
    _timerState = TimerState.stopped;
    notifyListeners();
  }

  void _onTick(Timer timer) {
    if (_remainingTime.inSeconds > 0) {
      _remainingTime -= const Duration(seconds: 1);
      notifyListeners();
    } else {
      _timer?.cancel();
      _remainingTime = Duration.zero; // Ensure exactly zero
      _timerState = TimerState.stopped;
      notifyListeners();
      if (onTimerFinished != null) {
        onTimerFinished!();
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerState = TimerState.stopped;
    super.dispose();
  }
}
