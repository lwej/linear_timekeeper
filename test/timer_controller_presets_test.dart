import 'package:flutter_test/flutter_test.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';

void main() {
  group('TimerController presetMinutesList', () {
    final testCases = <Map<String, dynamic>>[
      // 8 min: fixed intervals
      {
        'maxPresetMinutes': 8,
        'presetIntervalMinutes': 2,
        'expected': [2, 4, 6, 8],
      },
      // ----------- 20 min -----------
      // 20 min: 5, 10, 15, 20
      {
        'maxPresetMinutes': 20,
        'presetIntervalMinutes': 5,
        'expected': [5, 10, 15, 20],
      },
      // 20 min: 10, 20
      {
        'maxPresetMinutes': 20,
        'presetIntervalMinutes': 10,
        'expected': [10, 20],
      },
      // ----------- 30 min -----------
      // 30 min: 5, 10, 15, 20, 25, 30
      {
        'maxPresetMinutes': 30,
        'presetIntervalMinutes': 5,
        'expected': [5, 10, 15, 20, 25, 30],
      },
      // 30 min: 10, 20, 30
      {
        'maxPresetMinutes': 30,
        'presetIntervalMinutes': 10,
        'expected': [10, 20, 30],
      },
      // 30 min: 15, 30
      {
        'maxPresetMinutes': 30,
        'presetIntervalMinutes': 15,
        'expected': [15, 30],
      },
      // ----------- 40 min -----------
      // 40 min: 20, 40
      {
        'maxPresetMinutes': 40,
        'presetIntervalMinutes': 20,
        'expected': [20, 40],
      },
      // 40 min: 10, 20, 30, 40
      {
        'maxPresetMinutes': 40,
        'presetIntervalMinutes': 10,
        'expected': [10, 20, 30, 40],
      },

      // 40 min: 5, 10, 15, 20, 25, 30, 35, 40
      {
        'maxPresetMinutes': 40,
        'presetIntervalMinutes': 5,
        'expected': [5, 10, 15, 20, 25, 30, 35, 40],
      },

      // ----------- 60 min -----------
      // 60 min: 20, 40, 60
      {
        'maxPresetMinutes': 60,
        'presetIntervalMinutes': 20,
        'expected': [20, 40, 60],
      },
      // 60 min: 15, 30, 45, 60
      {
        'maxPresetMinutes': 60,
        'presetIntervalMinutes': 15,
        'expected': [15, 30, 45, 60],
      },
      // 60 min: 10, 20, 30, 40, 50, 60
      {
        'maxPresetMinutes': 60,
        'presetIntervalMinutes': 10,
        'expected': [10, 20, 30, 40, 50, 60],
      },
      // 60 min: 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60
      {
        'maxPresetMinutes': 60,
        'presetIntervalMinutes': 5,
        'expected': [5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60],
      },
      // ----------- 80 min -----------
      // 80 min: 20, 40, 60, 80
      {
        'maxPresetMinutes': 80,
        'presetIntervalMinutes': 20,
        'expected': [20, 40, 60, 80],
      },
      // 80 min: 10, 20, 30, 40, 50, 60, 70, 80
      {
        'maxPresetMinutes': 80,
        'presetIntervalMinutes': 10,
        'expected': [10, 20, 30, 40, 50, 60, 70, 80],
      },
      // 80 min: 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80
      {
        'maxPresetMinutes': 80,
        'presetIntervalMinutes': 5,
        'expected': [
          5,
          10,
          15,
          20,
          25,
          30,
          35,
          40,
          45,
          50,
          55,
          60,
          65,
          70,
          75,
          80
        ],
      },
      // None interval
      {
        'maxPresetMinutes': 20,
        'presetIntervalMinutes': 0,
        'expected': [],
      },
    ];

    for (final testCase in testCases) {
      test(
          'maxPresetMinutes=${testCase['maxPresetMinutes']}, presetIntervalMinutes=${testCase['presetIntervalMinutes']}',
          () {
        final controller = TimerController(
          initialDuration:
              Duration(minutes: testCase['maxPresetMinutes'] as int),
          maxPresetMinutes: testCase['maxPresetMinutes'] as int,
          presetIntervalMinutes: testCase['presetIntervalMinutes'] as int,
        );
        expect(controller.presetMinutesList, testCase['expected']);
      });
    }
  });
}
