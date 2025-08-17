import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'package:linear_timekeeper/model/timer_data.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({super.key});

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
  bool hasVibrator = false;

  @override
  void initState() {
    super.initState();
    _checkVibrator();
  }

  Future<void> _checkVibrator() async {
    final bool result = await Vibration.hasVibrator();
    if (mounted) {
      setState(() {
        hasVibrator = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<TimerData>(
        builder: (BuildContext context, TimerData timerData, Widget? child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              SwitchListTile(
                title: const Text('Enable Sound'),
                value: timerData.isSoundEnabled,
                onChanged: (bool value) {
                  timerData.toggleSound();
                },
                secondary: const Icon(Icons.volume_up),
              ),
              if (hasVibrator)
                SwitchListTile(
                  title: const Text('Enable Vibration'),
                  value: timerData.isVibrationEnabled,
                  onChanged: (bool value) {
                    timerData.toggleVibration();
                  },
                  secondary: const Icon(Icons.vibration),
                ),
              ListTile(
                title: const Text('Theme'),
                trailing: DropdownButton<ThemeMode>(
                  value: timerData.themeMode,
                  items: const [
                    DropdownMenuItem(
                        value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(
                        value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(
                        value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (mode) {
                    timerData.setThemeMode(mode!);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Licenses'),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'LinearTimekeeper',
                    //TODO: possible to use version from puspec?
                    applicationVersion: '0.1.0',
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
