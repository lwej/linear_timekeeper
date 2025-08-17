import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:linear_timekeeper/utils/progress_bar_utils.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'mocks/mock_timer_controller.mocks.dart';

void main() {
  group('calculateActiveDots', () {
    test('All dots active when selected preset is max', () {
      final dots = calculateActiveDots(
        dotsPerMinute: false,
        presets: [10, 20, 30, 40, 80],
        maxTotalDots: 20,
        totalDurationMinutes: 80,
        selectedMinutes: 80,
        remainingSeconds: 80 * 60,
        timerState: TimerState.initial,
        debugMode: false,
      );
      expect(dots, 20);
    });

    test('calculateActiveDots with empty presets falls back to duration', () {
      final dots = calculateActiveDots(
        dotsPerMinute: false,
        presets: [],
        maxTotalDots: 20,
        totalDurationMinutes: 20,
        selectedMinutes: 10,
        remainingSeconds: 10 * 60,
        timerState: TimerState.initial,
        debugMode: false,
      );
      expect(dots, 10);
    });
    test('Half dots active when selected preset is half', () {
      final dots = calculateActiveDots(
        dotsPerMinute: false,
        presets: [10, 20, 40, 80],
        maxTotalDots: 20,
        totalDurationMinutes: 80,
        selectedMinutes: 40,
        remainingSeconds: 40 * 60,
        timerState: TimerState.initial,
        debugMode: false,
      );
      expect(dots, 10);
    });

    test('dotsPerMinute true returns remainingMinutes', () {
      final dots = calculateActiveDots(
        dotsPerMinute: true,
        presets: [],
        maxTotalDots: 80,
        totalDurationMinutes: 80,
        selectedMinutes: 80,
        remainingSeconds: 60 * 60,
        timerState: TimerState.running,
        debugMode: false,
      );
      expect(dots, 60);
    });

    test('debugMode multiplies remainingSeconds by 60', () {
      final dots = calculateActiveDots(
        dotsPerMinute: false,
        presets: [10, 20, 40, 80],
        maxTotalDots: 20,
        totalDurationMinutes: 80,
        selectedMinutes: 40,
        remainingSeconds: 40,
        timerState: TimerState.running,
        debugMode: true,
      );
      // remainingSeconds = 40 * 60 = 2400, remainingMinutes = 40
      // (40/80)*20 = 10
      expect(dots, 10);
    });
  });

  group('shouldBlinkProgressBar with mock', () {
    test('returns true when timer is stopped and remainingTime is 0', () {
      final mockController = MockTimerController();
      when(mockController.timerState).thenReturn(TimerState.stopped);
      when(mockController.remainingTime).thenReturn(const Duration(seconds: 0));
      expect(shouldBlinkProgressBar(mockController), isTrue);
    });

    test('returns false when timer is running', () {
      final mockController = MockTimerController();
      when(mockController.timerState).thenReturn(TimerState.running);
      when(mockController.remainingTime).thenReturn(const Duration(seconds: 0));
      expect(shouldBlinkProgressBar(mockController), isFalse);
    });

    test('returns false when remainingTime is not 0', () {
      final mockController = MockTimerController();
      when(mockController.timerState).thenReturn(TimerState.running);
      when(mockController.remainingTime).thenReturn(const Duration(seconds: 5));
      expect(shouldBlinkProgressBar(mockController), isFalse);
    });
  });
}
