import 'package:linear_timekeeper/main.dart'; // TODO: Remove later (For the silly debugMode variable)

/// Formats a [Duration] object into a "MM:SS" string and if hour, "HH.MM:SS".
String formatDuration(Duration duration) {
  if (debugMode) {
    return '${duration.inSeconds}s';
  }
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final int hour = duration.inHours.remainder(60).abs().clamp(0, 59);
  final int minutes = duration.inMinutes.remainder(60).abs().clamp(0, 59);
  final int seconds = duration.inSeconds.remainder(60).abs().clamp(0, 59);
  if (hour > 0) {
    return '${twoDigits(hour)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
  }
  return '${twoDigits(minutes)}:${twoDigits(seconds)}';
}
