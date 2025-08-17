import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:linear_timekeeper/model/timer_data.dart';
import 'package:linear_timekeeper/types/custom_timer.dart';
import 'package:linear_timekeeper/utils/time_screen_utils.dart';

/// A screen to manage and select custom timers.
class TimerManagement extends StatelessWidget {
  const TimerManagement({super.key});

  /// Shows a confirmation dialog before deleting a custom timer.
  Future<void> _confirmDelete(
      BuildContext context, TimerData timerData, String timerId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Delete Timer'),
          content:
              const Text('Are you sure you want to delete this custom timer?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      timerData.deleteCustomTimer(timerId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Timer deleted.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Timers'),
      ),
      body: Consumer<TimerData>(
        builder: (BuildContext context, TimerData timerData, Widget? child) {
          if (timerData.customTimers.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'No custom timers saved yet. Go back to the main screen and use the "Save Current Timer" icon to add one!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: timerData.customTimers.length,
            itemBuilder: (BuildContext context, int index) {
              final CustomTimer timer = timerData.customTimers[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: ListTile(
                  title: Text(timer.title),
                  subtitle: Text(
                    '${formatDuration(timer.duration)}'
                    '${timer.maxPresetMinutes != null ? ' • Max: ${timer.maxPresetMinutes} min' : ''}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        _confirmDelete(context, timerData, timer.id),
                    tooltip: 'Delete Timer',
                  ),
                  onTap: () {
                    timerData.setCustomTimer(timer);
                    Navigator.of(context).pop(); // Go back to Home
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
