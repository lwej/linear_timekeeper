import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:linear_timekeeper/types/custom_timer.dart';

abstract class TimerStorage {
  Future<List<CustomTimer>> loadCustomTimers();
  Future<void> saveCustomTimers(List<CustomTimer> timers);
  Future<Map<String, dynamic>?> loadCustomTimerColorsMap();
  Future<void> saveCustomTimerColorsMap(Map<String, dynamic> colorsMap);
}

class SharedPreferencesTimerStorage implements TimerStorage {
  final Future<SharedPreferences> _prefsFuture;

  SharedPreferencesTimerStorage(this._prefsFuture);

  @override
  Future<List<CustomTimer>> loadCustomTimers() async {
    final SharedPreferences prefs = await _prefsFuture;
    final List<String>? customTimersJson = prefs.getStringList('customTimers');
    if (customTimersJson == null) {
      return <CustomTimer>[];
    }
    return customTimersJson
        .map<CustomTimer>((String jsonString) => CustomTimer.fromMap(
            json.decode(jsonString) as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> saveCustomTimers(List<CustomTimer> timers) async {
    final SharedPreferences prefs = await _prefsFuture;
    final List<String> customTimersJson = timers
        .map<String>((CustomTimer timer) => json.encode(timer.toMap()))
        .toList();
    await prefs.setStringList('customTimers', customTimersJson);
  }

  @override
  Future<Map<String, dynamic>?> loadCustomTimerColorsMap() async {
    final SharedPreferences prefs = await _prefsFuture;
    final String? colorsJson = prefs.getString('customTimerColors');
    if (colorsJson == null) {
      return null;
    }
    return json.decode(colorsJson) as Map<String, dynamic>;
  }

  @override
  Future<void> saveCustomTimerColorsMap(Map<String, dynamic> colorsMap) async {
    final SharedPreferences prefs = await _prefsFuture;
    await prefs.setString('customTimerColors', json.encode(colorsMap));
  }
}
