import 'package:flutter_test/flutter_test.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/utils/time_button_utils.dart';
import 'mocks/mock_timer_controller.mocks.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('getTimeButtonState with mock', () {
    test('returns active for current section', () {
      final mockController = MockTimerController();
      when(mockController.presetMinutesList).thenReturn([5, 10, 15, 20]);
      when(mockController.timerState).thenReturn(TimerState.initial);
      when(mockController.remainingTime)
          .thenReturn(const Duration(minutes: 20));
      when(mockController.duration).thenReturn(const Duration(minutes: 20));
      expect(
        getTimeButtonState(
          minutes: 10,
          timerController: mockController,
          debugMode: false,
        ),
        TimeButtonState.active,
      );
    });

    test('returns elapsed when running and section is elapsed', () {
      final mockController = MockTimerController();
      when(mockController.presetMinutesList).thenReturn([5, 10, 15, 20]);
      when(mockController.timerState).thenReturn(TimerState.running);
      when(mockController.remainingTime).thenReturn(const Duration(minutes: 0));
      when(mockController.duration).thenReturn(const Duration(minutes: 20));
      expect(
        getTimeButtonState(
          minutes: 5,
          timerController: mockController,
          debugMode: false,
        ),
        TimeButtonState.elapsed,
      );
    });

    test('returns future when not running and section is beyond selected', () {
      final mockController = MockTimerController();
      when(mockController.presetMinutesList).thenReturn([5, 10, 15, 20]);
      when(mockController.timerState).thenReturn(TimerState.initial);
      when(mockController.remainingTime)
          .thenReturn(const Duration(minutes: 20));
      when(mockController.duration).thenReturn(const Duration(minutes: 5));
      expect(
        getTimeButtonState(
          minutes: 10,
          timerController: mockController,
          debugMode: false,
        ),
        TimeButtonState.future,
      );
    });

    test('works in debugMode', () {
      final mockController = MockTimerController();
      when(mockController.presetMinutesList).thenReturn([5, 10, 15, 20]);
      when(mockController.timerState).thenReturn(TimerState.running);
      when(mockController.remainingTime).thenReturn(const Duration(seconds: 0));
      when(mockController.duration).thenReturn(const Duration(seconds: 20));
      expect(
        getTimeButtonState(
          minutes: 5,
          timerController: mockController,
          debugMode: true,
        ),
        TimeButtonState.elapsed,
      );
    });
  });
}
