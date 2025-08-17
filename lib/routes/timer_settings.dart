import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:linear_timekeeper/model/timer_color_manager.dart';
import 'package:linear_timekeeper/model/timer_data.dart';

import 'package:linear_timekeeper/theme/custom_timer_colors.dart';
import 'package:linear_timekeeper/widgets/color_settings.dart';

/// The settings screen where users can toggle various timer options.
class TimerSettings extends StatelessWidget {
  const TimerSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerData, FlavorModel>(
      builder: (BuildContext context, TimerData timerData,
          FlavorModel flavorModel, Widget? child) {
        final customColors = Theme.of(context).extension<CustomTimerColors>()!;
        final brightness = Theme.of(context).brightness;
        final flavor = flavorModel.activeFlavor(brightness);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Edit Timer'),
            actions: [
              IconButton(
                icon: Icon(
                  timerData.isEditingSavedTimer
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_add_rounded,
                ),
                onPressed: timerData.isEditingSavedTimer
                    ? null
                    : () async {
                        final existing = timerData.customTimers
                            .where(
                                (t) => t.title == timerData.timerTitle.trim())
                            .toList();
                        if (existing.isNotEmpty) {
                          final bool? confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Overwrite Timer?'),
                              content: Text(
                                  'A timer named "${timerData.timerTitle}" already exists. Overwrite it?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text('Overwrite'),
                                ),
                              ],
                            ),
                          );
                          if (confirm != true) return;
                          timerData.saveOrUpdateCurrentTimer(
                              overwriteId: existing.first.id);
                        } else {
                          timerData.saveOrUpdateCurrentTimer();
                        }
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('"${timerData.timerTitle}" saved!')),
                        );
                      },
                tooltip: timerData.isEditingSavedTimer
                    ? 'Timer already saved'
                    : 'Save Current Timer',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Timer',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              TextField(
                controller: TextEditingController(text: timerData.timerTitle),
                decoration: const InputDecoration(
                  labelText: 'Timer Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => timerData.setTimerTitle(value),
              ),
              const SizedBox(height: 16.0),
              ListTile(
                title: const Text('Timer Duration'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: timerData.timerController.maxPresetMinutes,
                    onChanged: (int? newValue) {
                      if (newValue != null) {
                        timerData.timerController.setMaxDuration(newValue);
                      }
                    },
                    items: const <DropdownMenuItem<int>>[
                      DropdownMenuItem<int>(
                        value: 8,
                        child: Text('8 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 20,
                        child: Text('20 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 30,
                        child: Text('30 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 40,
                        child: Text('40 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 60,
                        child: Text('60 minutes'),
                      ),
                      DropdownMenuItem<int>(
                        value: 80,
                        child: Text('80 minutes'),
                      ),
                    ],
                  ),
                ),
              ),
              if (timerData.timerController.maxPresetMinutes == 8)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Intervals: 2, 4, 6, 8 (fixed for 8 min timer)'),
                )
              else
                ListTile(
                  title: const Text('Timer Interval'),
                  trailing: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: timerData.timerController.presetIntervalMinutes,
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          timerData.timerController.setPresetInterval(newValue);
                        }
                      },
                      items: timerData.timerController
                          .getPresetIntervalDropdownItems(),
                    ),
                  ),
                ),
              SwitchListTile(
                title: const Text('Show Digital Time'),
                value: timerData.showDigitalTimer,
                onChanged: (value) => timerData.setShowDigitalTime(value),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child:
                    Text('Dots', style: Theme.of(context).textTheme.titleLarge),
              ),
              ListTile(
                title: const Text('Dot Size'),
                subtitle: Slider(
                  value: timerData.dotSize,
                  min: 10.0,
                  max: 100.0,
                  divisions: 20,
                  label: '${timerData.dotSize.toStringAsFixed(1)} px',
                  onChanged: (double value) {
                    timerData.setDotSize(value);
                  },
                ),
              ),
              SwitchListTile(
                title: const Text('Dots Per Minute'),
                value: timerData.dotsPerMinute,
                onChanged: (value) => timerData.setDotsPerMinute(value),
              ),
              ColorSettingTile(
                title: 'Active Dot Color',
                currentColor: customColors.activeDotColor,
                onColorChanged: (colorName) =>
                    timerData.setUserColorOverride('activeDotColor', colorName),
                onReset: () =>
                    timerData.clearUserColorOverride('activeDotColor'),
                colorItems: timerData.colorManager.getColorDropdownItems(
                    flavor,
                    timerData
                        .colorManager.userColorOverrides['activeDotColor']),
              ),
              ColorSettingTile(
                title: 'Inactive Dot Color',
                currentColor: customColors.inactiveDotColor,
                onColorChanged: (colorName) => timerData.setUserColorOverride(
                    'inactiveDotColor', colorName),
                onReset: () =>
                    timerData.clearUserColorOverride('inactiveDotColor'),
                colorItems: timerData.colorManager.getColorDropdownItems(
                    flavor,
                    timerData
                        .colorManager.userColorOverrides['inactiveDotColor']),
              ),
              const Divider(),
              if (timerData.timerController.presetMinutesList.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Time Button Colors',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              if (timerData.timerController.presetMinutesList.isNotEmpty)
                ...timerData.timerController.presetMinutesList
                    .map<Widget>((int minutes) {
                  return ColorSettingTile(
                    title: '$minutes Minute Button Color',
                    currentColor:
                        customColors.timeButtonColors[minutes] ?? Colors.grey,
                    onColorChanged: (colorName) =>
                        timerData.setUserColorOverride(
                            'timeButtonColor_$minutes', colorName),
                    onReset: () => timerData
                        .clearUserColorOverride('timeButtonColor_$minutes'),
                    colorItems: timerData.colorManager.getColorDropdownItems(
                        flavor,
                        timerData.colorManager
                            .userColorOverrides['timeButtonColor_$minutes']),
                  );
                }),
              if (timerData.timerController.presetMinutesList.isNotEmpty)
                ColorSettingTile(
                  title: 'Elapsed Button Color (Running Timer)',
                  currentColor: customColors.inactiveButtonColor,
                  onColorChanged: (colorName) => timerData.setUserColorOverride(
                      'inactiveButtonColor', colorName),
                  onReset: () =>
                      timerData.clearUserColorOverride('inactiveButtonColor'),
                  colorItems: timerData.colorManager.getColorDropdownItems(
                      flavor,
                      timerData.colorManager
                          .userColorOverrides['inactiveButtonColor']),
                ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Control Button Colors',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              ColorSettingTile(
                title: 'Play Button Color',
                currentColor: customColors.playButtonColor,
                onColorChanged: (colorName) => timerData.setUserColorOverride(
                    'playButtonColor', colorName),
                onReset: () =>
                    timerData.clearUserColorOverride('playButtonColor'),
                colorItems: timerData.colorManager.getColorDropdownItems(
                    flavor,
                    timerData
                        .colorManager.userColorOverrides['playButtonColor']),
              ),
              ColorSettingTile(
                title: 'Pause Button Color',
                currentColor: customColors.pauseButtonColor,
                onColorChanged: (colorName) => timerData.setUserColorOverride(
                    'pauseButtonColor', colorName),
                onReset: () =>
                    timerData.clearUserColorOverride('pauseButtonColor'),
                colorItems: timerData.colorManager.getColorDropdownItems(
                    flavor,
                    timerData
                        .colorManager.userColorOverrides['pauseButtonColor']),
              ),
              ColorSettingTile(
                title: 'Stop Button Color',
                currentColor: customColors.stopButtonColor,
                onColorChanged: (colorName) => timerData.setUserColorOverride(
                    'stopButtonColor', colorName),
                onReset: () =>
                    timerData.clearUserColorOverride('stopButtonColor'),
                colorItems: timerData.colorManager.getColorDropdownItems(
                    flavor,
                    timerData
                        .colorManager.userColorOverrides['stopButtonColor']),
              ),
            ],
          ),
        );
      },
    );
  }
}
