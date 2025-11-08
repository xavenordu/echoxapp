import 'package:hive/hive.dart';

part 'onboarding_status.g.dart';

@HiveType(typeId: 4)
class OnboardingStatus {
  @HiveField(0)
  final bool completed;

  @HiveField(1)
  final bool useCloudBackup;

  @HiveField(2)
  final DateTime? completedAt;

  @HiveField(3)
  final bool consentGiven;

  // 🆕 Added fields
  @HiveField(4)
  final bool darkMode;

  @HiveField(5)
  final bool notificationsEnabled;

  const OnboardingStatus({
    this.completed = false,
    this.useCloudBackup = false,
    this.completedAt,
    this.consentGiven = false,
    this.darkMode = false,
    this.notificationsEnabled = false,
  });

  OnboardingStatus copyWith({
    bool? completed,
    bool? useCloudBackup,
    DateTime? completedAt,
    bool? consentGiven,
    bool? darkMode,
    bool? notificationsEnabled,
  }) {
    return OnboardingStatus(
      completed: completed ?? this.completed,
      useCloudBackup: useCloudBackup ?? this.useCloudBackup,
      completedAt: completedAt ?? this.completedAt,
      consentGiven: consentGiven ?? this.consentGiven,
      darkMode: darkMode ?? this.darkMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
