import 'package:flutter/material.dart';
import 'package:catppuccin_flutter/catppuccin_flutter.dart';

import 'package:linear_timekeeper/theme/custom_timer_colors.dart';
import 'package:linear_timekeeper/utils/color_utils.dart';

ThemeData catppuccinTheme(Flavor flavor, Map<String, String> userColorOverrides,
    {required Brightness brightness}) {
  Color primaryColor = flavor.mauve;
  Color secondaryColor = flavor.pink;
  final resolvedColors = resolveAllTimerColors(flavor, userColorOverrides);

  return ThemeData(
    useMaterial3: true,
    appBarTheme: AppBarTheme(
        elevation: 10,
        titleTextStyle: TextStyle(
            color: flavor.text, fontSize: 20, fontWeight: FontWeight.bold),
        iconTheme: IconThemeData(color: flavor.surface2),
        backgroundColor: flavor.crust,
        foregroundColor: flavor.mantle),
    colorScheme: ColorScheme(
      brightness: brightness,
      error: flavor.surface2,
      onError: flavor.red,
      onPrimary: primaryColor,
      onSecondary: secondaryColor,
      onSurface: flavor.text,
      primary: flavor.crust,
      secondary: flavor.mantle,
      surface: flavor.surface0,
    ),
    textTheme: const TextTheme().apply(
      bodyColor: flavor.text,
      displayColor: primaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.selected)
              ? flavor.surface0
              : flavor.mauve),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (states) => states.contains(WidgetState.selected)
            ? flavor.mauve
            : flavor.surface0,
      ),
    ),
    listTileTheme: ListTileThemeData(
      textColor: flavor.text,
    ),
    extensions: <ThemeExtension<dynamic>>[
      CustomTimerColors(
        activeDotColor: resolvedColors['activeDotColor']!,
        inactiveDotColor: resolvedColors['inactiveDotColor']!,
        playButtonColor: resolvedColors['playButtonColor']!,
        pauseButtonColor: resolvedColors['pauseButtonColor']!,
        stopButtonColor: resolvedColors['stopButtonColor']!,
        inactiveButtonColor: resolvedColors['inactiveButtonColor']!,
        timeButtonColors: resolvedColors['timeButtonColors'] as Map<int, Color>,
      ),
    ],
  );
}
