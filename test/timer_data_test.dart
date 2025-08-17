import 'package:flutter_test/flutter_test.dart';
import 'package:linear_timekeeper/types/custom_timer.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/model/timer_color_manager.dart';
import 'package:linear_timekeeper/model/timer_storage.dart';

class MockTimerStorage implements TimerStorage {
  List<Map<String, dynamic>> savedTimers = [];
  Map<String, dynamic>? colorsMap;

  @override
  Future<List<CustomTimer>> loadCustomTimers() async => [];

  @override
  Future<void> saveCustomTimers(List<dynamic> timers) async {
    savedTimers = timers.map((e) => e.toMap() as Map<String, dynamic>).toList();
  }

  @override
  Future<Map<String, dynamic>?> loadCustomTimerColorsMap() async => colorsMap;

  @override
  Future<void> saveCustomTimerColorsMap(Map<String, dynamic> colorsMap) async {
    this.colorsMap = colorsMap;
  }
}

void main() {
  group('TimerData', () {
    late TimerData timerData;
    late MockTimerStorage storage;

    setUp(() {
      storage = MockTimerStorage();
      timerData = TimerData(
        storage: storage,
        colorManager: TimerColorManager(storage: storage),
        timerController: TimerController(
          initialDuration: const Duration(minutes: 5),
          maxPresetMinutes: 20,
          presetIntervalMinutes: 5,
        ),
      );
    });

    test('Initial title is Linear Timer', () {
      expect(timerData.timerTitle, 'Linear Timer');
    });

    test('setTimerTitle updates the title', () {
      timerData.setTimerTitle('New Title');
      expect(timerData.timerTitle, 'New Title');
    });

    test('toggleSound toggles sound', () {
      final initial = timerData.isSoundEnabled;
      timerData.toggleSound();
      expect(timerData.isSoundEnabled, !initial);
    });

    test('addCustomTimer adds a timer', () {
      timerData.addCustomTimer('My Timer', const Duration(minutes: 10));
      expect(timerData.customTimers.length, 1);
      expect(timerData.customTimers.first.title, 'My Timer');
    });

    test('updateCustomTimer updates timer fields', () {
      timerData.addCustomTimer('My Timer', const Duration(minutes: 10));
      final id = timerData.customTimers.first.id;
      timerData.updateCustomTimer(id, 'Updated', const Duration(minutes: 15));
      expect(timerData.customTimers.first.title, 'Updated');
      expect(
          timerData.customTimers.first.duration, const Duration(minutes: 15));
    });

    test('deleteCustomTimer removes a timer', () {
      timerData.addCustomTimer('My Timer', const Duration(minutes: 10));
      final id = timerData.customTimers.first.id;
      timerData.deleteCustomTimer(id);
      expect(timerData.customTimers, isEmpty);
    });
  });
}
