class CustomTimer {
  final String id;
  final String title;
  final Duration duration;
  final int? maxPresetMinutes;
  final int? presetIntervalMinutes;

  CustomTimer({
    required this.id,
    required this.title,
    required this.duration,
    this.maxPresetMinutes,
    this.presetIntervalMinutes,
  });

  /// Converts a [CustomTimer] object to a JSON-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'durationSeconds': duration.inSeconds,
      'maxPresetMinutes': maxPresetMinutes,
      'presetIntervalMinutes': presetIntervalMinutes,
    };
  }

  /// Creates a [CustomTimer] object from a map (e.g., loaded from JSON).
  factory CustomTimer.fromMap(Map<String, dynamic> map) {
    return CustomTimer(
      id: map['id'] as String,
      title: map['title'] as String,
      duration: Duration(seconds: map['durationSeconds'] as int),
      maxPresetMinutes: map['maxPresetMinutes'] as int?,
      presetIntervalMinutes: map['presetIntervalMinutes'] as int?,
    );
  }

  bool isSameSettings({
    required String title,
    required Duration duration,
    int? maxPresetMinutes,
    int? presetIntervalMinutes,
  }) {
    return this.title == title &&
        this.duration == duration &&
        this.maxPresetMinutes == maxPresetMinutes &&
        this.presetIntervalMinutes == presetIntervalMinutes;
  }
}
