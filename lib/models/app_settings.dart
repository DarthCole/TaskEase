/// this model is storing user preferences for reminders.
class AppSettings {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'soundEnabled': soundEnabled,
      'hapticsEnabled': hapticsEnabled,
    };
  }

  factory AppSettings.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AppSettings();
    }
    return AppSettings(
      soundEnabled: (map['soundEnabled'] ?? true) as bool,
      hapticsEnabled: (map['hapticsEnabled'] ?? true) as bool,
    );
  }

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return AppSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }
}
