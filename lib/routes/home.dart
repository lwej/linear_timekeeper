import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:linear_timekeeper/theme/custom_timer_colors.dart';
import 'package:linear_timekeeper/routes/app_settings.dart';
import 'package:linear_timekeeper/routes/timer_management.dart';
import 'package:linear_timekeeper/routes/timer_settings.dart';

import 'package:linear_timekeeper/widgets/dotted_progress_bar.dart';
import 'package:linear_timekeeper/widgets/timer_controls_row.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/widgets/time_buttons_row.dart';
import 'package:linear_timekeeper/widgets/manual_slider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

/// The main screen of the timer application, displaying the countdown and controls.
class _HomeState extends State<Home> {
  late final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final TimerData timerData = Provider.of<TimerData>(context);
    final customColors = Theme.of(context).extension<CustomTimerColors>()!;

    timerData.timerController.onTimerFinished = () async {
      if (timerData.isSoundEnabled) {
        await _audioPlayer.play(AssetSource(
            'sounds/762108__jerryberumen__alarm-clock-ringtone-marimba-rising-morning.wav'));
      }
      if (timerData.isVibrationEnabled) {
        if (await Vibration.hasVibrator()) {
          Vibration.vibrate(duration: 500); // Vibrate for 500ms
        }
      }
    };

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(
              child: Text(
                timerData.timerTitle,
              ),
            ),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Timer',
            onPressed: () {
              timerData.startNewTimer();
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const TimerSettings(),
                ),
              );
            },
            tooltip: 'Edit Timer',
          ),
          IconButton(
            icon: const Icon(Icons.list_alt_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const TimerManagement(),
                ),
              );
            },
            tooltip: 'My Timers',
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const AppSettings(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Consumer<TimerData>(
        builder: (BuildContext context, TimerData timerData, Widget? child) {
          final bool isRunning =
              timerData.timerController.timerState == TimerState.running;
          final bool isPaused =
              timerData.timerController.timerState == TimerState.paused;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                DottedProgressBar(
                  timerData: timerData,
                ),
                const SizedBox(height: 32),
                // Conditional display for Time Buttons or Manual Slider
                if (timerData.timerController.presetMinutesList.isNotEmpty)
                  TimeButtonsRow(timerData: timerData)
                else
                  ManualSlider(
                    timerData: timerData,
                    isRunning: isRunning,
                    isPaused: isPaused,
                  ),
                const SizedBox(height: 64),
                TimerControlsRow(
                  timerData: timerData,
                  customColors: customColors,
                  isRunning: isRunning,
                  isPaused: isPaused,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
