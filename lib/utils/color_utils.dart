import 'package:catppuccin_flutter/catppuccin_flutter.dart';
import 'package:flutter/material.dart';

Color getDesaturatedColor(Color color, [double amount = 0.3]) {
  return Color.lerp(color, Colors.grey, amount)!;
}

const List<int> kTimerPresetMinutes = [
  2,
  4,
  5,
  6,
  8,
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
];

const List<String> kTimerColorNames = [
  'Blue',
  'Flamingo',
  'Green',
  'Lavender',
  'Mantle',
  'Maroon',
  'Mauve',
  'Peach',
  'Pink',
  'Red',
  'Sapphire',
  'Sky',
  'Teal',
  'Yellow',
  'Surface0',
  'Surface1',
  'Surface2',
];

/// Returns a map of color name to Color for a given flavor.
Map<String, Color> getFlavorColorMap(Flavor flavor) {
  return {
    'Blue': flavor.blue,
    'Flamingo': flavor.flamingo,
    'Green': flavor.green,
    'Lavender': flavor.lavender,
    'Mantle': flavor.mantle,
    'Maroon': flavor.maroon,
    'Mauve': flavor.mauve,
    'Peach': flavor.peach,
    'Pink': flavor.pink,
    'Red': flavor.red,
    'Sapphire': flavor.sapphire,
    'Sky': flavor.sky,
    'Teal': flavor.teal,
    'Yellow': flavor.yellow,
    'Surface0': flavor.surface0,
    'Surface1': flavor.surface1,
    'Surface2': flavor.surface2,
  };
}

/// Centralized color cycle for default time button colors.
List<Color> getColorCycle(Flavor flavor) => [
      flavor.blue,
      flavor.flamingo,
      flavor.green,
      flavor.lavender,
      flavor.mantle,
      flavor.maroon,
      flavor.mauve,
      flavor.peach,
      flavor.pink,
      flavor.red,
      flavor.sapphire,
      flavor.sky,
      flavor.teal,
      flavor.yellow,
    ];

Map<String, dynamic> resolveAllTimerColors(
  Flavor flavor,
  Map<String, String> userColorOverrides, {
  List<int> presetMinutes = kTimerPresetMinutes,
}) {
  final colorMap = getFlavorColorMap(flavor);

  Color resolve(String key) {
    final colorName = userColorOverrides[key];
    if (colorName == null) return getDefaultColorForKey(key, flavor);
    if (colorMap.containsKey(colorName)) {
      return colorMap[colorName]!;
    }
    try {
      return Color(int.parse(colorName));
    } catch (_) {
      return getDefaultColorForKey(key, flavor);
    }
  }

  // Resolve time button colors
  final Map<int, Color> timeButtonColors = {};
  for (final minutes in presetMinutes) {
    final key = 'timeButtonColor_$minutes';
    timeButtonColors[minutes] = resolve(key);
  }

  return {
    'activeDotColor': resolve('activeDotColor'),
    'inactiveDotColor': resolve('inactiveDotColor'),
    'playButtonColor': resolve('playButtonColor'),
    'pauseButtonColor': resolve('pauseButtonColor'),
    'stopButtonColor': resolve('stopButtonColor'),
    'inactiveButtonColor': resolve('inactiveButtonColor'),
    'timeButtonColors': timeButtonColors,
  };
}

Color getDefaultColorForKey(String key, Flavor flavor) {
  final colorCycle = getColorCycle(flavor);
  if (key.startsWith('timeButtonColor_')) {
    final minutes = int.tryParse(key.split('_').last);
    if (minutes != null) {
      final idx = kTimerPresetMinutes.indexOf(minutes);
      if (idx != -1) {
        return colorCycle[idx % colorCycle.length];
      }
    }
    return flavor.surface0;
  }
  switch (key) {
    case 'activeDotColor':
      return flavor.mauve;
    case 'inactiveDotColor':
      return flavor.surface2;
    case 'playButtonColor':
      return flavor.green;
    case 'pauseButtonColor':
      return flavor.yellow;
    case 'stopButtonColor':
      return flavor.red;
    case 'inactiveButtonColor':
      return flavor.surface1;
    default:
      return flavor.mauve;
  }
}
