import 'package:flutter_test/flutter_test.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';

void main() {
  group('TimerController', () {
    test('Initial state is correct', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      expect(controller.duration, const Duration(minutes: 5));
      expect(controller.remainingTime, const Duration(minutes: 5));
      expect(controller.timerState, TimerState.initial);
    });

    test('setDuration updates duration and starts timer', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.setDuration(600); // 10 minutes
      expect(controller.duration, const Duration(seconds: 600));
      expect(controller.timerState, TimerState.running);
    });

    test('setManualDuration only works when not running or paused', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.setManualDuration(300);
      expect(controller.duration, const Duration(seconds: 300));
      controller.startTimer();
      controller.setManualDuration(600);
      expect(controller.duration, isNot(const Duration(seconds: 600)));
    });

    test('startTimer sets state to running', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.startTimer();
      expect(controller.timerState, TimerState.running);
    });

    test('pauseTimer sets state to paused', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.startTimer();
      controller.pauseTimer();
      expect(controller.timerState, TimerState.paused);
    });

    test('setMaxDuration updates maxPresetMinutes and resets timer', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.setMaxDuration(10);
      expect(controller.maxPresetMinutes, 10);
      expect(controller.duration, const Duration(minutes: 5));
      controller.setMaxDuration(8);
      expect(controller.maxPresetMinutes, 8);
      expect(controller.presetIntervalMinutes, 0); // Special case, none are set
      expect(controller.duration, const Duration(minutes: 2));
    });

    test('setPresetInterval updates presetIntervalMinutes and resets timer',
        () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.setPresetInterval(10);
      expect(controller.presetIntervalMinutes, 10);
      expect(controller.duration, const Duration(minutes: 10));
      controller.setPresetInterval(0);
      expect(controller.presetIntervalMinutes, 0);
      expect(controller.duration, const Duration(minutes: 20));
    });

    test('setPresetInterval ignores invalid intervals', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.setPresetInterval(7); // Not a valid interval
      expect(controller.presetIntervalMinutes, 5);
      controller.setPresetInterval(30); // Too large
      expect(controller.presetIntervalMinutes, 5);
    });

    test('startTimer does not start if already running or duration is zero',
        () {
      final controller = TimerController(
        initialDuration: Duration.zero,
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.startTimer();
      expect(controller.timerState, isNot(TimerState.running));

      final controller2 = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller2.startTimer();
      controller2.startTimer();
      expect(controller2.timerState, TimerState.running);
    });

    test('stopTimer sets state to stopped and resets remainingTime', () {
      final controller = TimerController(
        initialDuration: const Duration(minutes: 5),
        maxPresetMinutes: 20,
        presetIntervalMinutes: 5,
      );
      controller.startTimer();
      controller.stopTimer();
      expect(controller.timerState, TimerState.stopped);
      expect(controller.remainingTime, controller.duration);
    });

    test('timer ticks down and calls onTimerFinished', () async {
      final controller = TimerController(
        initialDuration: const Duration(seconds: 2),
        maxPresetMinutes: 2,
        presetIntervalMinutes: 1,
      );
      bool finished = false;
      controller.onTimerFinished = () {
        finished = true;
      };
      controller.startTimer();
      await Future.delayed(const Duration(seconds: 3));
      // Add a short delay to ensure the timer callback has run
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.remainingTime, Duration.zero);
      expect(controller.timerState, TimerState.stopped);
      expect(finished, true);
    });

    test('dispose cancels timer', () async {
      final controller = TimerController(
        initialDuration: const Duration(seconds: 2),
        maxPresetMinutes: 2,
        presetIntervalMinutes: 1,
      );
      controller.startTimer();
      controller.dispose();
      expect(controller.timerState, isNot(TimerState.running));
    });
  });
}

