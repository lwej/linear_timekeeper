import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:linear_timekeeper/main.dart'; // TODO: Remove later (For the silly debugMode variable)
import 'package:linear_timekeeper/model/timer_color_manager.dart';
import 'package:linear_timekeeper/model/timer_controller.dart';
import 'package:linear_timekeeper/model/timer_storage.dart';
import 'package:linear_timekeeper/types/custom_timer.dart';

class TimerData extends ChangeNotifier {
  final TimerStorage _storage;
  final TimerColorManager colorManager;
  final TimerController timerController;

  TimerData(
      {required TimerStorage storage,
      required this.colorManager,
      required this.timerController})
      : _storage = storage,
        _isSoundEnabled = true,
        _isVibrationEnabled = true,
        _timerTitle = 'Linear Timer', // Initial timer title
        _dotSize = 10.0, // Initial dot size
        //Dots are calculated and visualize per minute instead of fixed 20
        _dotsPerMinute = false,
        _showDigitalTimer = true, // Showing digital timer
        _themeMode = ThemeMode.system {
    // Listen to timerController and notify listeners when it changes
    timerController.addListener(notifyListeners);
    // Listen to colorManager and notify listeners when colors change
    colorManager.addListener(notifyListeners);
  }

  bool _isSoundEnabled;
  bool _isVibrationEnabled;
  String _timerTitle;
  List<CustomTimer> _customTimers = <CustomTimer>[];

  double _dotSize;
  bool _dotsPerMinute;
  bool _showDigitalTimer;
  ThemeMode _themeMode;

  String? _editingTimerId;

  /// Initializes the TimerData by loading saved state.
  Future<void> initialize() async {
    await _loadCustomTimers();
    await _loadDisplaySettings();
    notifyListeners(); // Notify listeners once all data is loaded
  }

  bool get isSoundEnabled => _isSoundEnabled;

  bool get isVibrationEnabled => _isVibrationEnabled;

  String get timerTitle => _timerTitle;

  List<CustomTimer> get customTimers => _customTimers;

  double get dotSize => _dotSize;

  bool get dotsPerMinute => _dotsPerMinute;

  bool get showDigitalTimer => _showDigitalTimer;

  ThemeMode get themeMode => _themeMode;

  String? get editingTimerId => _editingTimerId;

  void setCustomTimer(CustomTimer customTimer) {
    timerController.stopTimer();
    if (customTimer.maxPresetMinutes != null) {
      timerController.setMaxDuration(customTimer.maxPresetMinutes!);
    }
    if (customTimer.presetIntervalMinutes != null) {
      timerController.setPresetInterval(customTimer.presetIntervalMinutes!);
    }
    timerController.setManualDuration(customTimer.duration.inSeconds);
    setTimerTitle(customTimer.title);
    _editingTimerId = customTimer.id;
    notifyListeners();
  }

  void setUserColorOverride(String key, String colorName) =>
      colorManager.setUserColorOverride(key, colorName);

  void clearUserColorOverride(String key) =>
      colorManager.clearUserColorOverride(key);

  /// Returns the fraction of time remaining (0.0 to 1.0).
  /// Not used but kept for now
  double getProgressFraction() {
    const bool isDebug = debugMode;
    final int total = isDebug
        ? timerController.duration.inSeconds
        : timerController.duration.inMinutes;
    final int remaining = isDebug
        ? timerController.remainingTime.inSeconds
        : timerController.remainingTime.inMinutes;
    if (total == 0) return 0.0;
    return remaining / total;
  }

  /// Toggles the sound notification setting.
  void toggleSound() {
    _isSoundEnabled = !_isSoundEnabled;
    notifyListeners();
  }

  /// Toggles the vibration notification setting.
  void toggleVibration() {
    _isVibrationEnabled = !_isVibrationEnabled;
    notifyListeners();
  }

  /// Sets a new title for the timer.
  void setTimerTitle(String newTitle) {
    final String trimmedTitle = newTitle.trim();
    if (_timerTitle == trimmedTitle) return;
    _timerTitle = trimmedTitle;
    notifyListeners();
  }

  /// Saves the current timer's duration as a new custom timer with the given title.
  void addCustomTimer(String title, Duration duration) {
    final String trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) return; // Prevent saving empty title

    final CustomTimer newCustomTimer = CustomTimer(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: trimmedTitle,
      duration: duration,
      maxPresetMinutes: timerController.maxPresetMinutes,
      presetIntervalMinutes: timerController.presetIntervalMinutes,
    );
    _customTimers.add(newCustomTimer);
    _saveCustomTimers();
    notifyListeners();
  }

  /// Deletes a custom timer by its ID.
  void deleteCustomTimer(String id) {
    _customTimers.removeWhere((CustomTimer timer) => timer.id == id);
    _saveCustomTimers();
    notifyListeners();
  }

  /// Updates an existing custom timer with new title and duration.
  /// If the timer is not found, nothing happens.
  void updateCustomTimer(String id, String newTitle, Duration newDuration) {
    final int index = _customTimers.indexWhere((timer) => timer.id == id);
    if (index == -1) return;
    final String trimmedTitle = newTitle.trim();
    if (trimmedTitle.isEmpty) return;
    _customTimers[index] = CustomTimer(
      id: id,
      title: trimmedTitle,
      duration: newDuration,
      maxPresetMinutes: timerController.maxPresetMinutes,
      presetIntervalMinutes: timerController.presetIntervalMinutes,
    );
    _saveCustomTimers();
    notifyListeners();
  }

  // When user clicks "New Timer"
  void startNewTimer() {
    _editingTimerId = null;
    setTimerTitle('New Timer');
    timerController.setManualDuration(const Duration(minutes: 15).inSeconds);
    notifyListeners();
  }

  /// Saves the current timer as a new custom timer, or updates the timer being edited.
  void saveOrUpdateCurrentTimer({String? overwriteId}) {
    if (overwriteId != null) {
      // Overwrite existing timer with same id
      updateCustomTimer(
        overwriteId,
        _timerTitle,
        timerController.duration,
      );
      _editingTimerId = overwriteId;
    } else if (_editingTimerId != null) {
      // Update currently edited timer
      updateCustomTimer(
        _editingTimerId!,
        _timerTitle,
        timerController.duration,
      );
    } else {
      // Save as new timer
      addCustomTimer(_timerTitle, timerController.duration);
    }
  }

  /// Call this when starting a new timer (not editing an existing one)
  void clearEditingTimer() {
    _editingTimerId = null;
  }

  /// Loads custom timers from storage.
  Future<void> _loadCustomTimers() async {
    _customTimers = await _storage.loadCustomTimers();
  }

  /// Saves custom timers to storage.
  Future<void> _saveCustomTimers() async {
    await _storage.saveCustomTimers(_customTimers);
  }

  void setDotSize(double newSize) {
    if (_dotSize != newSize) {
      _dotSize = newSize;
      _saveDisplaySettings();
      notifyListeners();
    }
  }

  void setDotsPerMinute(bool value) {
    if (_dotsPerMinute != value) {
      _dotsPerMinute = value;
      _saveDisplaySettings();
      notifyListeners();
    }
  }

  void setShowDigitalTime(bool value) {
    if (_showDigitalTimer != value) {
      _showDigitalTimer = value;
      _saveDisplaySettings();
      notifyListeners();
    }
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      _saveDisplaySettings();
      // colorManager.clearDropdownCache();
      notifyListeners();
    }
  }

  /// Loads theme mode, dot size, and digital time settings from storage.
  Future<void> _loadDisplaySettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _dotSize = prefs.getDouble('dotSize') ?? 10.0;
    _dotsPerMinute = prefs.getBool('dotsPerMinute') ?? false;
    _showDigitalTimer = prefs.getBool('showDigitalTimer') ?? true;
    final String? themeModeStr = prefs.getString('themeMode');
    if (themeModeStr != null) {
      if (themeModeStr.contains('dark')) {
        setThemeMode(ThemeMode.dark);
      } else if (themeModeStr.contains('light')) {
        setThemeMode(ThemeMode.light);
      } else {
        setThemeMode(ThemeMode.system);
      }
    }
  }

  /// Saves visual settings to storage.
  Future<void> _saveDisplaySettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('dotSize', _dotSize);
    await prefs.setBool('dotsPerMinute', _dotsPerMinute);
    await prefs.setBool('showDigitalTimer', _showDigitalTimer);
    await prefs.setString('themeMode', _themeMode.toString());
  }

  CustomTimer? _findCustomTimerById(String? id) {
    if (id == null) return null;
    for (final timer in _customTimers) {
      if (timer.id == id) return timer;
    }
    return null;
  }

  bool get isEditingSavedTimer {
    final timer = _findCustomTimerById(_editingTimerId);
    if (timer == null) return false;
    return timer.isSameSettings(
      title: _timerTitle,
      duration: timerController.duration,
      maxPresetMinutes: timerController.maxPresetMinutes,
      presetIntervalMinutes: timerController.presetIntervalMinutes,
    );
  }

  //FIXME: Should be removed or implemented
  bool get hasUnsavedChanges {
    // If not editing a saved timer, always allow saving (new timer)
    if (_editingTimerId == null) {
      // Only consider as "unsaved" if the title or duration is not empty/default
      return _timerTitle.trim().isNotEmpty &&
          timerController.duration.inSeconds > 0;
    }
    // Find the timer being edited
    final timer = _findCustomTimerById(_editingTimerId);
    if (timer == null) return false;
    // Compare current settings to saved timer
    return timer.title != _timerTitle ||
        timer.duration != timerController.duration;
  }

  Future<void> handleSaveTimer(BuildContext context, String? savedTitle) async {
    if (savedTitle != null && savedTitle.trim().isNotEmpty) {
      final trimmedTitle = savedTitle.trim();
      final existing =
          customTimers.where((t) => t.title == trimmedTitle).toList();
      if (existing.isNotEmpty) {
        final bool? confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Overwrite Timer?'),
            content: Text(
                'A timer named "$trimmedTitle" already exists. Overwrite it?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Overwrite'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
        // Only update title if user changed it
        if (timerTitle != trimmedTitle) {
          setTimerTitle(trimmedTitle);
        }
        saveOrUpdateCurrentTimer(overwriteId: existing.first.id);
      } else {
        // New timer, set title and save
        setTimerTitle(trimmedTitle);
        saveOrUpdateCurrentTimer();
      }
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$trimmedTitle" saved!'),
        ),
      );
    }
  }

  @override
  void dispose() {
    timerController.removeListener(notifyListeners);
    timerController.dispose();
    super.dispose();
  }
}
