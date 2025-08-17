import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

import 'package:linear_timekeeper/model/timer_color_manager.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/model/timer_storage.dart';
import 'package:linear_timekeeper/routes/home.dart';
import 'package:linear_timekeeper/theme/theme.dart';

// TODO: Remove at some point
// Used to run the timer in seconds instead of minutes
const bool debugMode = false;

/// The main application widget for the linear_timekeeper app.
class LinearTimekeeper extends StatelessWidget {
  const LinearTimekeeper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerData, FlavorModel>(
      builder: (BuildContext context, TimerData timerData,
          FlavorModel flavorModel, Widget? child) {
        // Determine flavor for light/dark mode
        final ThemeMode themeMode = timerData.themeMode;
        final Flavor lightFlavor = flavorModel.lightFlavor;
        final Flavor darkFlavor = flavorModel.darkFlavor;

        return MaterialApp(
          title: 'LinearTimekeeper',
          theme: catppuccinTheme(
            lightFlavor,
            timerData.colorManager.userColorOverrides,
            brightness: Brightness.light,
          ),
          darkTheme: catppuccinTheme(
            darkFlavor,
            timerData.colorManager.userColorOverrides,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          home: const Home(),
        );
      },
    );
  }
}

/// The entry point of the Flutter application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  final Future<SharedPreferences> prefsFuture = SharedPreferences.getInstance();
  final SharedPreferencesTimerStorage storage =
      SharedPreferencesTimerStorage(prefsFuture);
  final TimerColorManager colorManager = TimerColorManager(storage: storage);
  await colorManager.loadColorSettings();
  final timerController = TimerController(
    initialDuration: const Duration(minutes: 15),
    maxPresetMinutes: 20,
    presetIntervalMinutes: 5,
  );
  final TimerData timerData = TimerData(
    storage: storage,
    colorManager: colorManager,
    timerController: timerController,
  );
  await timerData.initialize(); // Initialize data model after creation

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<TimerData>.value(value: timerData),
        ChangeNotifierProvider<FlavorModel>(
          create: (_) => FlavorModel(
            lightFlavor: catppuccin.latte,
            darkFlavor: catppuccin.mocha,
          ),
        ),
      ],
      child: const LinearTimekeeper(),
    ),
  );
}
