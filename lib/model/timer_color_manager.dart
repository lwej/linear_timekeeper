import 'package:flutter/material.dart';

import 'package:catppuccin_flutter/catppuccin_flutter.dart';

import 'package:linear_timekeeper/model/timer_storage.dart';
import 'package:linear_timekeeper/utils/color_utils.dart';

class TimerColorManager extends ChangeNotifier {
  final TimerStorage _storage;
  Map<String, String> _userColorOverrides = {};

  TimerColorManager({required TimerStorage storage}) : _storage = storage;

  Map<String, String> get userColorOverrides => _userColorOverrides;

  List<MapEntry<String, Color>> getColorChoices(Flavor flavor) {
    final colorMap = getFlavorColorMap(flavor);
    return kTimerColorNames
        .map((name) => MapEntry(name, colorMap[name]!))
        .toList();
  }

  final Map<Flavor, List<DropdownMenuItem<Color>>> _dropdownCache = {};

  void clearDropdownCache() {
    _dropdownCache.clear();
  }

  List<DropdownMenuItem<Color>> getColorDropdownItems(Flavor flavor,
      [String? selectedColorName]) {
    final colorChoices = getColorChoices(flavor);
    final items = colorChoices
        .map((entry) => DropdownMenuItem<Color>(
              value: entry.value,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: entry.value,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(entry.key),
                ],
              ),
            ))
        .toList();

    if (selectedColorName != null &&
        !kTimerColorNames.contains(selectedColorName)) {
      try {
        final customColor = Color(int.parse(selectedColorName));
        return [
          ...items,
          DropdownMenuItem<Color>(
            value: customColor,
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: customColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black12),
                  ),
                ),
                const SizedBox(width: 8),
                const Text("Custom"),
              ],
            ),
          ),
        ];
      } catch (_) {}
    }
    return items;
  }

  void setUserColorOverride(String key, String colorName) {
    if (_userColorOverrides[key] == colorName) return;
    _userColorOverrides[key] = colorName;
    clearDropdownCache();
    saveColorSettings();
    notifyListeners();
  }

  void clearUserColorOverride(String key) {
    if (_userColorOverrides.containsKey(key)) {
      _userColorOverrides.remove(key);
      clearDropdownCache();
      saveColorSettings();
      notifyListeners();
    }
  }

  Future<void> loadColorSettings() async {
    final loadedMap = await _storage.loadCustomTimerColorsMap();
    if (loadedMap != null) {
      _userColorOverrides = Map<String, String>.fromEntries(
        loadedMap.entries
            .where((e) => e.value is String)
            .map((e) => MapEntry(e.key, e.value as String)),
      );
      clearDropdownCache();
      notifyListeners();
    }
  }

  Future<void> saveColorSettings() async {
    await _storage.saveCustomTimerColorsMap(_userColorOverrides);
  }
}

// FIXME: Could be integrated into TimerColorManager...
/// FlavorModel for providing the current Catppuccin flavor app-wide.
class FlavorModel extends ChangeNotifier {
  Flavor _lightFlavor;
  Flavor _darkFlavor;

  FlavorModel({Flavor? lightFlavor, Flavor? darkFlavor})
      : _lightFlavor = lightFlavor ?? catppuccin.latte,
        _darkFlavor = darkFlavor ?? catppuccin.mocha;

  Flavor get lightFlavor => _lightFlavor;
  Flavor get darkFlavor => _darkFlavor;

  set lightFlavor(Flavor flavor) {
    _lightFlavor = flavor;
    notifyListeners();
  }

  set darkFlavor(Flavor flavor) {
    _darkFlavor = flavor;
    notifyListeners();
  }
}

extension FlavorModelActive on FlavorModel {
  /// Returns the correct flavor for the given [brightness].
  Flavor activeFlavor(Brightness brightness) =>
      brightness == Brightness.dark ? darkFlavor : lightFlavor;
}
